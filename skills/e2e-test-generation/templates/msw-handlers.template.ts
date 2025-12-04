import { http, HttpResponse } from 'msw';

export const handlers = [
  // Example: Authentication endpoint
  http.post('/api/auth/callback/credentials', async ({ request }) => {
    const body = await request.json();
    const { email, password } = body as { email: string; password: string };

    if (email === 'test@example.com' && password === 'password123') {
      return HttpResponse.json({
        user: {
          email,
          name: 'Test User',
          role: 'USER',
        },
      });
    }

    return HttpResponse.json(
      { error: 'Invalid credentials' },
      { status: 401 }
    );
  }),

  {{API_HANDLERS}}
];
