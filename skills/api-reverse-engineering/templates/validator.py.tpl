#!/usr/bin/env python3
"""
{{PLATFORM}} API Validation Script
Daily health checks for schema, row counts, and file integrity
"""
import sys
import json
from pathlib import Path
from datetime import datetime
import pandas as pd
import logging

sys.path.insert(0, str(Path(__file__).parent.parent))

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[logging.StreamHandler()]
    )
    return logging.getLogger(__name__)

def validate_csv_schema(csv_path: Path, expected_columns: list, entity_name: str, logger, encoding='utf-8') -> bool:
    """Validate CSV has expected columns"""
    try:
        df = pd.read_csv(csv_path, nrows=1, encoding=encoding)
        actual_cols = set(df.columns)
        expected_cols = set(expected_columns)

        if not expected_cols.issubset(actual_cols):
            missing = expected_cols - actual_cols
            logger.error(f"❌ {entity_name}: Missing columns: {missing}")
            return False

        logger.info(f"✅ {entity_name}: Schema valid")
        return True
    except Exception as e:
        logger.error(f"❌ {entity_name}: Failed to read CSV: {e}")
        return False

def validate_row_count(csv_path: Path, min_rows: int, entity_name: str, logger, encoding='utf-8') -> tuple[bool, int]:
    """Validate CSV has minimum row count"""
    try:
        df = pd.read_csv(csv_path, encoding=encoding)
        actual_rows = len(df)

        if actual_rows < min_rows:
            logger.warning(f"⚠️  {entity_name}: Row count {actual_rows} below threshold {min_rows}")
            return False, actual_rows

        logger.info(f"✅ {entity_name}: {actual_rows:,} rows")
        return True, actual_rows
    except Exception as e:
        logger.error(f"❌ {entity_name}: Failed to count rows: {e}")
        return False, 0

def check_file_sizes_differ(download_dir: Path, logger) -> bool:
    """Verify files have different sizes (detect parameter errors)"""
    csv_files = list(download_dir.glob("*.csv"))
    if len(csv_files) < 2:
        return True

    sizes = {f.name: f.stat().st_size for f in csv_files}
    unique_sizes = set(sizes.values())

    if len(unique_sizes) == 1:
        logger.error(f"❌ All CSV files identical size ({list(sizes.values())[0]} bytes)")
        logger.error("   This indicates API is returning same data for all entities")
        return False

    logger.info(f"✅ File sizes vary ({len(unique_sizes)} unique sizes)")
    return True

def main():
    logger = setup_logging()

    project_root = Path(__file__).parent.parent
    download_dir = project_root / "downloads" / "latest"
    config_path = project_root / "config" / "expected_schemas.json"

    logger.info("="*60)
    logger.info("{{PLATFORM}} API Validation Check")
    logger.info("="*60)

    if not download_dir.exists():
        logger.error(f"Download directory not found: {download_dir}")
        sys.exit(1)

    with open(config_path, 'r') as f:
        expected_schemas = json.load(f)

    all_valid = True
    issues = []

    if not check_file_sizes_differ(download_dir, logger):
        all_valid = False
        issues.append("All CSV files identical (API parameter issue)")

    for entity_name, schema in expected_schemas.items():
        csv_path = download_dir / entity_name

        if not csv_path.exists():
            logger.warning(f"⚠️  {entity_name}: File not found")
            continue

        encoding = schema.get('encoding', 'utf-8')
        schema_valid = validate_csv_schema(
            csv_path,
            schema.get('key_columns', []),
            entity_name,
            logger,
            encoding
        )

        row_valid, row_count = validate_row_count(
            csv_path,
            schema.get('min_rows', 0),
            entity_name,
            logger,
            encoding
        )

        if not schema_valid:
            all_valid = False
            issues.append(f"{entity_name}: Schema mismatch")

        if not row_valid:
            issues.append(f"{entity_name}: Low row count ({row_count})")

    logger.info("="*60)

    if all_valid and len(issues) == 0:
        logger.info("✅ All validations passed")
    elif len(issues) > 0 and all_valid:
        logger.warning(f"⚠️  Validation completed with {len(issues)} warnings")
    else:
        logger.error(f"🚨 Validation failed: {len(issues)} critical issues")
        sys.exit(1)

if __name__ == "__main__":
    main()
