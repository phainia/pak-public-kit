#!/usr/bin/env python3
"""
Binary config decoder: .bytes data + .non schema -> readable JSON.
"""
import struct, json, math, sys
from pathlib import Path
from typing import Any

PRIMITIVE_FORMATS = {
    "EUint32": "<I", "EInt32": "<i", "EFloat": "<f",
    "EUint64": "<Q", "EInt64": "<q", "EDouble": "<d",
    "EUint16": "<H", "EInt16": "<h",
}

def safe_decode_text(blob: bytes) -> str:
    blob = blob.split(b"\x00", 1)[0]
    if not blob: return ""
    try: return blob.decode("utf-8")
    except: return blob.decode("utf-8", errors="replace").replace("\x00", "").strip()

class BinTableParser:
    """Parse a single .bytes table using its .non schema"""
    def __init__(self, data: bytes, schema: dict,
                 loc_data = None):
        self.data = data
        self.schema = schema
        self.properties = schema["Properties"]

        # Footer: last 64 bytes = 16 uint32s
        self.meta = struct.unpack("<" + "I" * 16, self.data[-64:])
        self.row_count = self.meta[3]
        self.struct_size = self.meta[4]
        self.row_index_offset = self.meta[6]
        self.row_index_end = self.meta[9]
        self.ref_count = self.meta[11]
        self.ref_blob_offset = self.meta[12]
        self.ref_blob_length = self.meta[14]

        self.refs = self._load_refs(data)
        self.loc_refs = self._load_localized_refs(loc_data) if loc_data else {}

    def _load_refs(self, data: bytes) -> dict[int, bytes]:
        refs: dict[int, bytes] = {}
        if self.ref_count == 0:
            return refs
        # Ref section starts at row_index_end, ends at footer (len - 64)
        section = data[self.row_index_end:len(data) - 64]
        section = section[:self.ref_count * 16]
        for offset in range(0, len(section), 16):
            ref_id, size, blob_offset, _ = struct.unpack("<IIII", section[offset:offset+16])
            refs[ref_id] = data[blob_offset:blob_offset + size]
        return refs

    def _load_localized_refs(self, data: bytes) -> dict[int, bytes]:
        refs: dict[int, bytes] = {}
        meta = struct.unpack("<" + "I" * 8, data[-32:])
        idx_off = meta[1]
        ref_count = meta[3]
        section = data[idx_off:idx_off + ref_count * 16]
        for offset in range(0, len(section), 16):
            ref_id, size, blob_offset, _ = struct.unpack("<IIII", section[offset:offset+16])
            refs[ref_id] = data[blob_offset:blob_offset + size]
        return refs

    def encoded_size(self, prop: dict) -> int:
        t = prop["Type"]
        if t in PRIMITIVE_FORMATS:
            return struct.calcsize(PRIMITIVE_FORMATS[t])
        if t in {"EBool", "EUint8", "EInt8"}:
            return 1
        if "CompressedSize" in prop:
            return prop["CompressedSize"]
        return prop.get("Size", 4)

    def read_primitive(self, prop_type: str, raw: bytes) -> Any:
        if prop_type == "EBool": return raw[0] != 0
        if prop_type == "EUint8": return raw[0]
        if prop_type == "EInt8": return struct.unpack("<b", raw)[0]
        return struct.unpack(PRIMITIVE_FORMATS[prop_type], raw)[0]

    def decode_ref_blob(self, prop: dict, blob: bytes) -> Any:
        t = prop["Type"]
        if t in {"EString", "ELocalizedString"}:
            return safe_decode_text(blob)
        if prop.get("DynamicArray"):
            inner = dict(prop)
            inner.pop("DynamicArray", None)
            if inner["Type"] == "EStruct":
                return self.decode_struct_array(inner["Struct"], blob)
            inner_size = self.encoded_size(inner)
            return [self.decode_value(inner, blob[o:o+inner_size])
                    for o in range(0, len(blob), inner_size)
                    if o + inner_size <= len(blob)]
        if t == "EStruct":
            sd = prop["Struct"]
            if prop.get("ArrayDim", 1) > 1:
                return self.decode_struct_array(sd, blob)
            return self.decode_struct(sd, blob)
        if len(blob) == self.encoded_size(prop):
            return self.read_primitive(t, blob)
        return {"_raw_hex": blob.hex()}

    def decode_struct(self, struct_def: dict, blob: bytes) -> dict:
        result = {}
        cursor = 0
        for prop in struct_def["Properties"]:
            size = self.encoded_size(prop)
            raw = blob[cursor:cursor + size]
            if len(raw) < size: break
            result[prop["Name"]] = self.decode_value(prop, raw)
            cursor += size
        return result

    def decode_struct_array(self, struct_def: dict, blob: bytes) -> list:
        item_size = sum(self.encoded_size(p) for p in struct_def["Properties"])
        return [self.decode_struct(struct_def, blob[o:o+item_size])
                for o in range(0, len(blob), item_size)
                if o + item_size <= len(blob)]

    def decode_value(self, prop: dict, raw: bytes) -> Any:
        t = prop["Type"]
        if t == "ELocalizedString":
            ref_id = struct.unpack("<I", raw)[0]
            blob = self.loc_refs.get(ref_id)
            return safe_decode_text(blob) if blob else ref_id
        if t in {"EString", "EStruct"} or prop.get("DynamicArray"):
            ref_id = struct.unpack("<I", raw)[0]
            blob = self.refs.get(ref_id)
            return self.decode_ref_blob(prop, blob) if blob else ref_id
        return self.read_primitive(t, raw)

    def parse_row(self, row_idx: int) -> dict:
        _, row_size, row_offset = self.row_infos[row_idx]
        row_data = self.data[row_offset:row_offset + row_size]
        bitmap_bytes = math.ceil(len(self.properties) / 8)
        bitmap = row_data[:bitmap_bytes]
        present = []
        for bm in bitmap:
            present.extend((bm >> shift) & 1 for shift in range(7, -1, -1))

        result = {}
        cursor = bitmap_bytes
        for idx, prop in enumerate(self.properties):
            if not present[idx]: continue
            size = self.encoded_size(prop)
            raw = row_data[cursor:cursor + size]
            cursor += size
            result[prop["Name"]] = self.decode_value(prop, raw)
        return result

    def parse_all(self) -> list[dict]:
        # Load row infos
        rows = []
        section = self.data[self.row_index_offset:self.row_index_offset + self.row_count * 16]
        for offset in range(0, len(section), 16):
            row_key, row_size, row_offset, _ = struct.unpack("<IIII", section[offset:offset+16])
            rows.append((row_key, row_size, row_offset))
        self.row_infos = rows
        return [self.parse_row(i) for i in range(len(rows))]


# ── Batch processor ──
def process(temp_dir: str, output_dir: str):
    temp = Path(temp_dir)
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    # Step 1: Load schemas from .non files (which are JSON!)
    print("[1/3] Loading schemas...")
    schemas = {}
    for nf in sorted(temp.rglob("*.non")):
        try:
            schemas[nf.stem] = json.loads(nf.read_text(encoding='utf-8'))
        except: pass
    print(f"  Loaded {len(schemas)} schemas")

    # Step 2: Index localization files
    print("[2/3] Indexing localizations...")
    locs = {}  # name -> lang -> raw bytes
    for f in sorted(temp.rglob("*.bytes")):
        if 'BinLocalize' not in str(f): continue
        parts = f.parts
        try:
            idx = parts.index('BinLocalize')
            lang = parts[idx + 1]
        except: continue
        locs.setdefault(f.stem, {})[lang] = f.read_bytes()
    print(f"  Found localizations for {len(locs)} tables")

    # Step 3: Decode .bytes
    print("[3/3] Decoding .bytes → JSON...")
    decoded = 0
    for bf in sorted(temp.rglob("*.bytes")):
        if 'BinLocalize' in str(bf): continue
        if 'BinDataCompressed' not in str(bf) and 'BinData' not in str(bf): continue

        name = bf.stem
        schema = schemas.get(name)
        if not schema: continue

        try:
            data = bf.read_bytes()
            loc_raw = None
            if name in locs and 'zh_CN' in locs[name]:
                loc_raw = locs[name]['zh_CN']

            parser = BinTableParser(data, schema, loc_raw)
            rows = parser.parse_all()

            with open(out / f"{name}.json", 'w', encoding='utf-8') as f:
                json.dump(rows, f, ensure_ascii=False, indent=2)
            decoded += 1
            print(f"  OK {name} ({len(rows)} rows)")
        except Exception as e:
            print(f"  SKIP {name}: {e}")

    print(f"\nDecoded {decoded} tables → {out}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 decode_configs.py <temp-dir> [output-dir]")
        sys.exit(1)
    temp_dir = sys.argv[1]
    out_dir = sys.argv[2] if len(sys.argv) > 2 else "../output/json"
    process(temp_dir, out_dir)
