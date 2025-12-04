#!/usr/bin/env python3
"""
{{PLATFORM}} Authentication Module
Session-based authentication using cookies
"""
import requests
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class {{PLATFORM}}Auth:
    def __init__(self, base_url: str):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()

    def login(self, username: str, password: str) -> Optional[str]:
        """
        Authenticate and return session ID
        Returns: Session ID string or None on failure
        """
        login_url = f"{self.base_url}/{{LOGIN_ENDPOINT}}"

        payload = {
            'username': username,
            'password': password,
            # Add platform-specific fields here
        }

        try:
            response = self.session.post(login_url, data=payload, timeout=30)

            if response.status_code != 200:
                logger.error(f"Login failed: HTTP {response.status_code}")
                return None

            # Extract session ID from cookie
            session_id = self.session.cookies.get('{{SESSION_COOKIE_NAME}}')

            if not session_id:
                logger.error("Session cookie not found in response")
                return None

            logger.info(f"Login successful: {username}")
            return session_id

        except requests.exceptions.RequestException as e:
            logger.error(f"Login request failed: {e}")
            return None

    def is_session_valid(self, session_id: str) -> bool:
        """
        Verify session is still valid
        """
        test_url = f"{self.base_url}/{{VALIDATION_ENDPOINT}}"

        try:
            response = self.session.get(test_url, timeout=10)

            is_valid = (
                response.status_code == 200 and
                '{{SUCCESS_INDICATOR}}' in response.text.lower()
            )

            if is_valid:
                logger.info("Session valid")
            else:
                logger.warning("Session expired")

            return is_valid

        except requests.exceptions.RequestException as e:
            logger.error(f"Session validation failed: {e}")
            return False

    def get_session(self) -> requests.Session:
        """
        Get authenticated session for making requests
        """
        return self.session
