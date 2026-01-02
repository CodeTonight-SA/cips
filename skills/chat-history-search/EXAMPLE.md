# `/remind-yourself` Command Examples

Quick reference for using the chat history search skill.

---

## Basic Usage

```bash
/remind-yourself <topic/keywords>
```text

---

## Example 1: Resume Previous Work

### User Input:
```text
/remind-yourself oculus backend refactoring
```text

### Claude's Action:
```bash
rg -i "oculus.*backend|nextauth|cognito|stripe|refactor" ~/.claude/history.jsonl -C 10 | head -200
```text

### Expected Output:
```markdown
# Context from Past Sessions

**Search Query:** "oculus.*backend|nextauth|cognito|stripe|refactor"
**Results Found:** 12 relevant entries
**Most Recent:** Nov 6, 2025

## Summary

You were implementing backend integration for the Oculus Tech website. The project
involved migrating from a static Vite SPA to Next.js with NextAuth.js + AWS Cognito
authentication, Stripe payments, and S3 downloads.

## Key Decisions
- ✅ Migrated to Next.js for server-side auth (completed Nov 6)
- ✅ Fixed "Bad ID Token" error with Cognito issuer mismatch
- ✅ Separated .env (non-secrets) from .env.local (secrets)
- ⏳ Stripe integration ready (awaiting Gareth's company account setup)

## Files Created/Modified
- `pages/api/auth/[...nextauth].ts` - NextAuth config with Cognito
- `pages/_app.tsx` - SessionProvider wrapper
- `pages/download.tsx` - Protected download page with license check
- `.env` / `.env.local` - Environment variable separation

## Current Status
- ✅ Microsoft sign-in working
- ⏳ Pending: S3 IAM user credentials
- ⏳ Pending: Stripe webhook testing
- ⏳ Pending: .exe file upload to S3

## Next Steps
1. Create IAM user for S3 access (don't use root credentials)
2. Upload installer to S3 bucket: `oculus-dwgcom-releases-d33573`
3. Test Stripe checkout flow with test card
4. Verify webhook creates license in RDS

**Location:** `/path/to/your/project/`
**Plan Document:** `website_backend_refactoring.md`
```text

---

## Example 2: Recall Solution to Error

### User Input:
```text
/remind-yourself how we fixed the bad token error
```text

### Claude's Action:
```bash
rg -i "bad.*token|id.*token.*error|cognito.*issuer" ~/.claude/history.jsonl -C 8 | head -150
```text

### Expected Output:
```markdown
# Context from Past Sessions

**Search Query:** "bad.*token|id.*token.*error|cognito.*issuer"
**Results Found:** 3 relevant entries

## Summary

You encountered a "Bad id_token issuer" error when testing Microsoft authentication
through Cognito. The error occurred because the issuer URL was coming from Microsoft
directly instead of through Cognito.

## The Error
```text
http://localhost:3000/api/auth/callback/cognito?
error_description=Bad+id_token+issuer+
https%3A%2F%2Flogin.microsoftonline.com%2F7663ad0c-c232-4ba6-b562-42a924c0e38b%2Fv2.0
&error=invalid_request
```text

## The Fix

**File:** `pages/api/auth/[...nextauth].ts`

### Change:
- Verified `COGNITO_ISSUER` in `.env.local` matches Cognito User Pool
- Set `checks: 'nonce'` in CognitoProvider config
- Ensured redirect URI in Microsoft Entra matches Cognito callback URL

**Root Cause:** Microsoft Entra ID redirect URI wasn't properly pointing to Cognito's
hosted UI endpoint. Updated to:
```text
https://oculus-dwgcom-auth-d33573.auth.me-central-1.amazoncognito.com/oauth2/idpresponse
```text

## Result
✅ Authentication flow working: User → Cognito → Microsoft → Cognito → Website
```text

---

## Example 3: Find Past Planning Documents

### User Input:
```text
/remind-yourself terminal setup tmux zsh
```text

### Claude's Action:
```bash
rg -i "terminal.*setup|tmux.*config|zsh.*keybind" ~/.claude/history.jsonl -C 5 | head -200
```text

### Expected Output:
```markdown
# Context from Past Sessions

**Search Query:** "terminal.*setup|tmux.*config|zsh.*keybind"
**Results Found:** 8 relevant entries
**Most Recent:** Nov 6, 2025

## Summary

You optimized your macOS terminal configuration for native text editing with select+delete
functionality. The project involved configuring zsh ZLE, tmux, iTerm2, micro editor,
and Cursor IDE terminal.

## Key Achievements
- ✅ Created ZLE region-aware delete functions in `~/.zshrc`
- ✅ Enabled text selection + backspace deletion in terminal
- ✅ Configured tmux with mouse support and macOS clipboard integration
- ✅ Added Shift+Enter for new line in terminal (Cursor + micro)
- ✅ Created comprehensive Medium article documenting the process

## Files Created/Modified
- `~/.tmux.conf` - tmux configuration (new file)
- `~/.zshrc` - ZLE functions and keybindings (90 lines added)
- `~/.config/micro/bindings.json` - Shift+Enter binding
- `~/Library/Application Support/Cursor/User/keybindings.json` - Terminal keybindings
- `~/TERMINAL_SHORTCUTS.md` - Quick reference guide
- `~/medium_terminal_optimisation.md` - Medium article

## Technical Solution

**The Magic:** ZLE region-aware functions that check `$REGION_ACTIVE`:
```bash
function backward-delete-char-or-region() {
  if [[ $REGION_ACTIVE -eq 1 ]]; then
    zle kill-region
  else
    zle backward-delete-char
  fi
}
```text

## Next Steps
1. Enable iTerm2 "Natural Text Editing" preset (manual)
2. Reload zsh: `source ~/.zshrc`
3. Test: Shift+Arrow to select, Backspace to delete
```text

---

## Example 4: Project Timeline

### User Input:
```text
/remind-yourself what have we done on example project
```text

### Claude's Action:
```bash
rg '"project":"/Users/username/projects/example-app"' ~/.claude/history.jsonl |
rg "display" |
tail -n 30
```text

### Expected Output:
```markdown
# Context from Past Sessions

**Project:** Example App
**Path:** `/Users/username/projects/example-app`
**Sessions Found:** 4

## Timeline

### Session 1 (Nov 6, 2025 - Morning)
- UI enhancements to login page using Figma design
- Made login form more compact (no vertical scroll on laptop)
- Used background image asset

### Session 2 (Nov 6, 2025 - Afternoon)
- Implemented easter egg confetti animation on app logo text
- Created interactive confetti with mini houses/skyscrapers
- Added mouse movement interaction (swirl effect)
- Made confetti persist until keypress released

## Recent Activity (Last 3 Prompts)
1. "Add enhancement to make animation slow down when button pressed longer"
2. "It should not stop when mouse pressed again - INCREASE BLAST RADIUS"
3. "Make confetti stay on screen until keydown expiry reached"

## Files Modified
- `app/auth/login/page.tsx` - Login UI improvements
- `app/auth/register/page.tsx` - Easter egg animation

## Current Status
✅ Login page matches Figma design
✅ Easter egg animation working with physics
⏸️ No active tasks
```text

---

## Example 5: Cross-Session Knowledge Transfer

### User Input:
```text
/remind-yourself stripe payment integration patterns
```text

### Expected Output:
```markdown
# Context from Past Sessions

**Search Query:** "stripe.*payment|stripe.*checkout|stripe.*webhook"
**Results Found:** 15 relevant entries across 2 projects

## Pattern Found in Multiple Projects

### Oculus Tech Website (Nov 6, 2025)
### Implementation
- Stripe Checkout Session creation via `/api/checkout`
- Webhook handling via Lambda function (AWS)
- Automatic license creation in RDS after payment
- Test mode active (awaiting production keys)

**Files:** `pages/api/checkout.ts`, `pages/pricing.tsx`

### Similar Pattern Previously Used
You've implemented Stripe Checkout flows before with similar architecture:
- Create session with metadata (user_id, email)
- Redirect to Stripe hosted checkout
- Handle webhook for `checkout.session.completed`
- Update database with payment confirmation

## Best Practices Learned
1. Always use `.env.local` for Stripe secret keys
2. Test with card `4242 4242 4242 4242` in test mode
3. Verify webhook signature before processing
4. Store `stripe_payment_id` in database for reconciliation
5. Use `metadata` field to pass user context through checkout

## Reusable Code Snippet
```typescript
const checkoutSession = await stripe.checkout.sessions.create({
  payment_method_types: ['card'],
  line_items: [...],
  mode: 'payment',
  success_url: `${process.env.NEXTAUTH_URL}/pricing?session_id={CHECKOUT_SESSION_ID}`,
  cancel_url: `${process.env.NEXTAUTH_URL}/pricing?canceled=true`,
  customer_email: email,
  metadata: { user_id: userId }
});
```text
```text

---

## Command Aliases

All of these work the same way:

```bash
/remind-yourself <topic>
/history <topic>
/recall <topic>
/remember <topic>
```text

---

## Tips for Better Results

### ✅ Good Queries (Specific Keywords)
```text
/remind-yourself nextauth cognito bad token
/remind-yourself stripe webhook lambda
/remind-yourself terminal zsh select delete
```text

### ❌ Poor Queries (Too Broad)
```text
/remind-yourself help          # Too vague
/remind-yourself code          # Too generic
/remind-yourself yesterday     # No keywords
```text

### 🔥 Pro Tips
- Combine 2-3 specific keywords
- Include technology names (NextAuth, Stripe, tmux)
- Reference error messages or file names
- Add project name for disambiguation

---

**Last Updated:** 2025-11-06
