# Animal Life Cycle Rescue Mission

Grade 4 Science educational game covering life cycles of the **butterfly**, **frog**, **chicken** (context), and **human** (theme).  
Built with **HTML + CSS + vanilla JavaScript + Supabase** (no backend server).

---

## Files

| File | Purpose |
|------|---------|
| `index.html` | Student game (join with name + session code) |
| `teacher.html` | Teacher dashboard (create session, live scores) |
| `supabase_setup.sql` | Tables + RLS policies + Realtime |
| `README.md` | This guide |

---

## 1. Supabase setup (one-time)

### A. Create a project
1. Go to [https://supabase.com](https://supabase.com) and sign in.
2. Click **New project**.
3. Choose a name, password, and region. Wait until the project is ready.

### B. Enable Anonymous Sign-Ins
1. In the left sidebar: **Authentication** → **Providers**.
2. Find **Anonymous Sign-Ins** and turn it **ON**.
3. Save.

### C. Run the SQL
1. Open **SQL Editor** → **New query**.
2. Copy the entire contents of `supabase_setup.sql` and paste it.
3. Click **Run**.
4. Confirm there are no errors.

### D. Get your URL and anon key
1. Go to **Project Settings** → **API**.
2. Copy:
   - **Project URL** (e.g. `https://abcdefgh.supabase.co`)
   - **anon / public** key (long JWT starting with `eyJ...`)

### E. Put the keys in both HTML files
Open `index.html` and `teacher.html`. Near the top of the `<script>` section find:

```js
const SUPABASE_URL = 'YOUR_SUPABASE_PROJECT_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Replace both values with your real Project URL and anon key.  
**Never** put the `service_role` key in the frontend.

---

## 2. Run locally

1. Put `index.html` and `teacher.html` in the same folder.
2. Open them in a browser:
   - Double-click the files, **or**
   - Use a simple static server (recommended for Realtime):
     ```bash
     npx serve .
     # or: python -m http.server 8080
     ```
3. Open `teacher.html` first → create a session → copy the code.
4. Open `index.html` (or the link with `?session=CODE`) → enter name + code → play.

---

## 3. Host for class (Zoom / Google Meet)

Any static host works:

- **GitHub Pages**: push the folder to a repo → Settings → Pages → deploy from main branch.
- **Netlify / Cloudflare Pages / Vercel**: drag-and-drop the folder or connect the repo.
- After hosting, the student link will look like:  
  `https://yoursite.netlify.app/index.html?session=FROG1234`

Share that link or the short session code in the meeting chat.

---

## 4. Teacher flow during a live demo (5–7 minutes)

1. Open **teacher.html** on your computer (or the hosted version).
2. Click **Create New Session**. Share the big session code (or the Copy Link button).
3. Share your screen so students can see the live dashboard.
4. Students open the student link, type their **display name** and the **session code**, then click **Join Mission**.
5. Guide them:
   - **Mission 1** – drag/click the four butterfly stages into order.
   - **Mission 2** – order the frog stages + choose the habitat (pond/wetland).
   - **Mission 3** – three quick multiple-choice questions.
6. Watch scores and progress update live on your dashboard.
7. When finished: **Close Session** or **Reset Session** for the next group.

---

## 5. Scoring (editable in `index.html`)

| Question | Points |
|----------|--------|
| Butterfly order | 20 |
| Frog order | 15 |
| Frog habitat | 15 |
| Quiz 1 / 2 / 3 | 10 each |
| **Total** | **80** |

Change the `POINTS` object and the question arrays in `index.html` to customize.

---

## 6. Design notes

- Colorful science-lab theme, large buttons, responsive for laptop / tablet / phone.
- Sound is optional and only plays after a user click (no autoplay).
- No email or password is ever requested — only a display name and session code.
- Encouraging feedback; wrong answers are never shaming.

---

## 7. Troubleshooting

| Problem | Fix |
|---------|-----|
| “Invalid session code” | Make sure the session is still active and the code matches exactly. |
| Join fails / auth error | Confirm Anonymous Sign-Ins is enabled in Supabase Auth providers. |
| Dashboard does not update live | Check that the SQL added the tables to `supabase_realtime` publication. Refresh the page. |
| CORS / blocked | Serve the files over `http://` or `https://`, not `file://`, when testing Realtime. |
| RLS errors | Re-run the full `supabase_setup.sql` script. |

---

## 8. Security note (classroom demo)

Policies allow reading participants/answers by session code for the teacher dashboard. This is intentional for a simple classroom demo. For a public production app you would add teacher authentication and stricter ownership checks.

Enjoy the mission! 🦋🐸
