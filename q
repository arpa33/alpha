# Mobile Bill Inquiry (Example)

This repository contains a simple, **safe**, and **GitHub-ready** example for querying a mobile bill using a provider's HTTP API. It is a template — replace the fictional endpoints and API keys with the real provider's API and integration details.

> ⚠️ Important: This project assumes you have permission from the mobile account owner and the mobile provider to request billing information via API. Never attempt to access accounts you are not authorized to access.

---

## What this repo contains

* **README** (this file): instructions and examples.
* **Node.js example**: `src/server.js` — small Express app that proxies requests to a telecom API using an API key.
* **Python CLI example**: `examples/check_bill.py` — simple script showing how to call the provider API.

All code examples below are included in this README for convenience — copy them into your repo files.

---

## Prerequisites

* Node.js 18+ (for the Node example)
* Python 3.8+ (for the Python example)
* An API key or OAuth credentials from your mobile provider (replace placeholder values)

---

## Environment

Create a `.env` file (not committed to git) with values like:

```
PROVIDER_BASE_URL=https://api.example-telecom.com/v1
PROVIDER_API_KEY=your_api_key_here
PORT=3000
```

---

## Node.js (Express) example — `src/server.js`

```javascript
// src/server.js
import express from 'express';
import fetch from 'node-fetch';
import dotenv from 'dotenv';

dotenv.config();
const app = express();
app.use(express.json());

const BASE_URL = process.env.PROVIDER_BASE_URL;
const API_KEY = process.env.PROVIDER_API_KEY;

// Simple endpoint to check a mobile bill by phone number (example only)
app.get('/bill/:phone', async (req, res) => {
  const phone = req.params.phone;
  try {
    const resp = await fetch(`${BASE_URL}/bills?phone=${encodeURIComponent(phone)}`, {
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Accept': 'application/json'
      }
    });

    if (!resp.ok) {
      const text = await resp.text();
      return res.status(resp.status).json({ error: 'Provider error', details: text });
    }

    const data = await resp.json();
    // sanitize/limit sensitive fields before returning to front-end
    const safe = {
      phone: data.phone,
      total_due: data.total_due,
      due_date: data.due_date,
      last_payment: data.last_payment || null
    };
    res.json(safe);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server running on port ${port}`));
```

### Notes (Node)

* Use HTTPS. Do not log API keys or full responses with sensitive data.
* Rate-limit your endpoint if exposing publicly.
* Add authentication (JWT, OAuth) on your proxy to avoid exposing the provider API key to clients.

---

## Python CLI example — `examples/check_bill.py`

```python
# examples/check_bill.py
import os
import requests
import sys
from dotenv import load_dotenv

load_dotenv()
BASE_URL = os.getenv('PROVIDER_BASE_URL')
API_KEY = os.getenv('PROVIDER_API_KEY')

if len(sys.argv) < 2:
    print('Usage: python check_bill.py +15551234567')
    sys.exit(1)

phone = sys.argv[1]

resp = requests.get(
    f"{BASE_URL}/bills",
    params={"phone": phone},
    headers={"Authorization": f"Bearer {API_KEY}", "Accept": "application/json"},
    timeout=10,
)
resp.raise_for_status()

data = resp.json()
print('Phone:', data.get('phone'))
print('Total due:', data.get('total_due'))
print('Due date:', data.get('due_date'))
```

---

## How to test locally

1. Add `.env` file with your provider base URL and API key.
2. Run Node example:

```bash
npm init -y
npm install express node-fetch dotenv
node --experimental-modules src/server.js
```

3. Or run Python example:

```bash
python -m pip install requests python-dotenv
python examples/check_bill.py "+15551234567"
```

---

## Security & Privacy

* Never commit `.env` or any secrets to git. Use `.gitignore`.
* Use provider's official SDKs when available — they often handle retries, auth, and errors better.
* Log only non-sensitive metadata. Redact personal data when storing logs.
* Follow local laws about accessing and storing billing data and personal information.

---

## Extending this project

* Add OAuth flow if the provider requires delegated access.
* Add caching for frequent queries.
* Add unit tests and integration tests using mocked provider responses.

---

## License

Use any open-source license you prefer (MIT is simple and permissive).
