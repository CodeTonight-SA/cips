import { renderHook, waitFor } from '@testing-library/react';
import { renderWithProviders } from '@/src/test-utils';
import { {{HOOK_NAME}} } from './{{HOOK_FILE}}';

describe('{{HOOK_NAME}}', () => {
  it('fetches data successfully', async () => {
    const { result } = renderHook(() => {{HOOK_NAME}}({{PARAMS}}), {
      wrapper: ({ children }) => renderWithProviders(<>{children}</>).wrapper,
    });

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true);
    });

    expect(result.current.data).toBeDefined();
    {{ASSERTIONS}}
  });

  it('handles loading state', () => {
    const { result } = renderHook(() => {{HOOK_NAME}}({{PARAMS}}), {
      wrapper: ({ children }) => renderWithProviders(<>{children}</>).wrapper,
    });

    expect(result.current.isLoading).toBe(true);
    expect(result.current.data).toBeUndefined();
  });

  it('handles error state', async () => {
    const { result } = renderHook(() => {{HOOK_NAME}}({{INVALID_PARAMS}}), {
      wrapper: ({ children }) => renderWithProviders(<>{children}</>).wrapper,
    });

    await waitFor(() => {
      expect(result.current.isError).toBe(true);
    });

    expect(result.current.error).toBeDefined();
  });

  it('refetches data when parameters change', async () => {
    const { result, rerender } = renderHook(
      ({ params }) => {{HOOK_NAME}}(params),
      {
        initialProps: { params: {{INITIAL_PARAMS}} },
        wrapper: ({ children }) => renderWithProviders(<>{children}</>).wrapper,
      }
    );

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true);
    });

    const firstData = result.current.data;

    rerender({ params: {{UPDATED_PARAMS}} });

    await waitFor(() => {
      expect(result.current.data).not.toEqual(firstData);
    });
  });
});
