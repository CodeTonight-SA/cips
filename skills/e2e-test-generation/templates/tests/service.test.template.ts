import { describe, it, expect } from 'vitest';
import { {{SERVICE_NAME}} } from './{{SERVICE_FILE}}';

describe('{{SERVICE_NAME}}', () => {
  describe('{{METHOD_NAME}}', () => {
    it('successfully {{METHOD_DESCRIPTION}}', async () => {
      const result = await {{SERVICE_NAME}}.{{METHOD_NAME}}({{PARAMS}});

      expect(result).toBeDefined();
      expect(result.data).toBeDefined();
      {{ASSERTIONS}}
    });

    it('handles error when {{ERROR_CONDITION}}', async () => {
      await expect(
        {{SERVICE_NAME}}.{{METHOD_NAME}}({{INVALID_PARAMS}})
      ).rejects.toThrow();
    });

    it('validates input parameters', async () => {
      await expect(
        {{SERVICE_NAME}}.{{METHOD_NAME}}({})
      ).rejects.toThrow(/required|invalid/i);
    });
  });
});
