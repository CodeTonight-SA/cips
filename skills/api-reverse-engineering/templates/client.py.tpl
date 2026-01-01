#!/usr/bin/env python3
"""
{{PLATFORM}} API Client
Handles entity downloads using authenticated session
"""
import requests
from pathlib import Path
from typing import Optional, Dict, List
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
import logging
import json

logger = logging.getLogger(__name__)

class {{PLATFORM}}Client:
    def __init__(self, base_url: str, session: requests.Session, company_id: str = None):
        self.base_url = base_url.rstrip('/')
        self.session = session
        self.company_id = company_id

        # Load entity mapping
        config_path = Path(__file__).parent.parent / 'config' / 'entity_mapping.json'
        with open(config_path, 'r') as f:
            config = json.load(f)
            self.entities = config['entities']

    def download_entity(self, entity_name: str, output_dir: Path) -> Optional[Path]:
        """
        Download single entity CSV

        Args:
            entity_name: Name of entity to download
            output_dir: Directory to save CSV

        Returns:
            Path to downloaded file or None on failure
        """
        entity_config = next((e for e in self.entities if e['name'] == entity_name), None)
        if not entity_config:
            logger.error(f"Entity {entity_name} not found in mapping")
            return None

        export_url = f"{self.base_url}/{{EXPORT_ENDPOINT}}"

        # Build payload using entity-specific form key
        payload = {}
        if self.company_id:
            payload['comp_id'] = self.company_id

        # Critical: Use entity-specific discriminator key
        payload[entity_config['form_key']] = 'Export'

        try:
            response = self.session.post(
                export_url,
                data=payload,
                timeout=60,
                stream=True
            )

            if response.status_code != 200:
                logger.error(f"{entity_name}: HTTP {response.status_code}")
                return None

            # Save to timestamped directory
            output_dir.mkdir(parents=True, exist_ok=True)
            output_path = output_dir / entity_config['filename']

            with open(output_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)

            file_size = output_path.stat().st_size
            logger.info(f"✓ {entity_name}: {file_size:,} bytes")

            return output_path

        except requests.exceptions.RequestException as e:
            logger.error(f"{entity_name}: Download failed - {e}")
            return None

    def download_all(self, output_dir: Path, max_workers: int = 3) -> Dict[str, Path]:
        """
        Download all entities in parallel

        Args:
            output_dir: Directory to save CSVs
            max_workers: Max concurrent downloads

        Returns:
            Dict mapping entity name to file path
        """
        results = {}

        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = {
                executor.submit(self.download_entity, entity['name'], output_dir): entity['name']
                for entity in self.entities
            }

            for future in as_completed(futures):
                entity_name = futures[future]
                try:
                    file_path = future.result()
                    if file_path:
                        results[entity_name] = file_path
                except Exception as e:
                    logger.error(f"{entity_name}: Exception - {e}")

        logger.info(f"Downloaded {len(results)}/{len(self.entities)} entities")
        return results
