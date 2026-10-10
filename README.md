# 屁屁×屁眼 港澳之旅

2027/1/14–1/19 香港＋澳門的拋棄式旅遊 App（PWA）。

- 網站：GitHub Pages
- 資料庫、登入、照片：Supabase（Email 驗證碼登入，只有名單內的 Email 能讀寫）
- 天氣：Open-Meteo；匯率：ExchangeRate-API（皆免金鑰）

## 設定
1. Supabase 建立專案，SQL Editor 執行 `supabase/setup.sql`（把名單 Email 換掉）。
2. Authentication → Email Templates → Magic Link：內文加入 `{{ .Token }}`，讓信裡有 6 位數驗證碼。
3. 把 Project URL 與 anon public key 填進 `config.js`。
4. GitHub repo → Settings → Pages → Deploy from branch → `main` / root。
