# Case Study: Hosting a Secure Static Business Website on AWS

**Project 1 | Week 1 | AWS Cloud Portfolio Series**

---

## 1. Business Scenario (fictional but realistic)

> Company: **NimbusCraft Interiors** — a small furniture & home-decor business based in Pune, India.
> Problem: Unhappy with their old shared-hosting website — slow loading for customers outside India, no HTTPS (browser shows "Not Secure"), and monthly hosting bills that keep rising even though the site is just a 6-page brochure site (Home, About, Products, Gallery, Contact, Blog).
> Ask: A fast, secure, low-cost website that loads quickly whether the visitor is in Mumbai or in Melbourne.

This is a genuinely common real-world use case — small business marketing sites, portfolio sites, documentation sites, and landing pages are very often static (HTML/CSS/JS, no backend/database), which makes them perfect for this architecture. Framing it around a real company like this is exactly what makes a portfolio project look credible to recruiters — it shows you can map a business problem to the right AWS services, not just follow a tutorial.

---

## 2. Solution Architecture

**Flow:** User Browser → Route 53 (DNS) → CloudFront (CDN + HTTPS) → S3 Bucket (Origin, static files) — with an ACM SSL certificate attached to CloudFront.

| Layer | Service | Role |
|---|---|---|
| DNS | Route 53 | Maps `www.nimbuscraft.com` to the CloudFront distribution |
| CDN / Edge | CloudFront | Caches content at edge locations worldwide, terminates HTTPS |
| SSL/TLS | AWS Certificate Manager (ACM) | Free public SSL certificate, auto-renewed |
| Storage / Origin | S3 (Static website hosting) | Stores HTML/CSS/JS/images, private bucket accessed only via CloudFront |

**Why this stack (talking points for interviews/LinkedIn):**
- No EC2/servers to patch or scale — fully serverless, near-zero maintenance
- CloudFront's global edge network cuts latency for visitors far from your S3 region
- ACM certificate is free (vs. ~₹1,000–8,000/year for a paid SSL cert)
- Pay-per-use pricing — costs scale with actual traffic, not a fixed server rental

---

## 3. Step-by-Step Build (and exactly what to screenshot)

Take a screenshot at each ✅ checkpoint — these become your portfolio evidence.

### Step 1 — S3 Bucket Setup
1. Create S3 bucket, name it to match domain convention, e.g. `nimbuscraft-website-prod`
2. Uncheck "Block all public access" **only if** serving directly from S3 (if using CloudFront + OAC, keep it blocked instead — more secure, see Section 5)
3. Enable **Static website hosting** in bucket properties, set index document = `index.html`, error document = `error.html`
4. Upload your site files (`index.html`, `style.css`, `images/`, etc.)

✅ Screenshot: bucket properties page showing "Static website hosting: Enabled" + the bucket endpoint URL

### Step 2 — Request an SSL Certificate (ACM)
1. Go to **Certificate Manager**, request a public certificate
2. Add domain names: `nimbuscraft.com` and `www.nimbuscraft.com`
3. Choose **DNS validation** (faster, and integrates directly with Route 53 — one-click "Create records in Route 53" button)
4. Wait for status to change to **Issued**

⚠️ Important real-world detail: the certificate **must be requested in the `us-east-1` (N. Virginia) region** — CloudFront only reads ACM certs from us-east-1, regardless of where your S3 bucket lives. This is a classic beginner mistake, mentioning it in your writeup signals real hands-on experience.

✅ Screenshot: certificate detail page showing status "Issued"

### Step 3 — Create the CloudFront Distribution
1. Origin domain: select your S3 bucket (use the REST API endpoint, not the website endpoint, if using Origin Access Control)
2. Origin access: **Origin Access Control (OAC)** — this keeps the S3 bucket fully private; only CloudFront can read it
3. Viewer protocol policy: **Redirect HTTP to HTTPS**
4. Alternate domain names (CNAMEs): `www.nimbuscraft.com`
5. Custom SSL certificate: select the ACM cert from Step 2
6. Default root object: `index.html`

✅ Screenshot: distribution settings page showing domain name, SSL cert attached, and status "Deployed"

### Step 4 — Update the S3 Bucket Policy
Attach a bucket policy that allows only the specific CloudFront distribution to read objects (AWS auto-generates this when you set up OAC — just click "Copy policy" and paste into the S3 bucket policy editor).

✅ Screenshot: bucket policy JSON in the S3 console

### Step 5 — Route 53 DNS Configuration
1. If domain is registered elsewhere, create a **Hosted Zone** in Route 53 and update nameservers at the registrar
2. Create an **A record** (Alias) pointing `www.nimbuscraft.com` → your CloudFront distribution
3. Optionally add a redirect from the root domain to `www`

✅ Screenshot: Route 53 record set showing the Alias record targeting the CloudFront domain

### Step 6 — Test
- Visit `https://www.nimbuscraft.com` → confirm padlock/HTTPS
- Try `http://` version → confirm auto-redirect to HTTPS
- Use a tool like [tools like GTmetrix or a VPN] to confirm fast load times from a different geographic region

✅ Screenshot: browser address bar showing the padlock icon + your custom domain

---

## 4. Cost Breakdown (realistic monthly estimate)

Assuming a small business site: ~10 GB storage, ~50 GB CloudFront data transfer/month, ~2 million requests/month (moderate traffic).

| Service | Usage assumption | Estimated monthly cost (USD) |
|---|---|---|
| S3 Standard Storage | 10 GB | ~$0.23 |
| S3 PUT/GET requests | ~50,000 requests | ~$0.02 |
| CloudFront data transfer out | 50 GB | ~$4.25 (first 1TB tier, varies by edge location) |
| CloudFront HTTPS requests | 2,000,000 requests | ~$1.50 |
| ACM SSL Certificate | Public cert, CloudFront-attached | **$0.00 (free)** |
| Route 53 Hosted Zone | 1 zone | $0.50 |
| Route 53 DNS queries | ~1,000,000 queries | ~$0.40 |
| **Total estimate** | | **~$6.90 / month (~₹575)** |

**Comparison point for your writeup:** shared hosting + a paid SSL cert + a CDN add-on for the same site would typically run ₹1,500–4,000/month for comparable performance — a good "before vs after" narrative for LinkedIn.

*(Always double-check current pricing on the [AWS Pricing Calculator](https://calculator.aws) before quoting numbers publicly — rates vary by region and change over time.)*

---

## 5. Security Settings (document these — recruiters look for this)

| Setting | Configuration | Why it matters |
|---|---|---|
| S3 Bucket Access | **Block all public access = ON**, private bucket | Prevents anyone from bypassing CloudFront and hitting S3 directly |
| Origin Access | Origin Access Control (OAC) | Only your CloudFront distribution can fetch objects from S3 |
| Bucket Policy | Scoped to a single CloudFront distribution ARN via condition key | Least-privilege — no wildcard access |
| Transport | Viewer protocol policy = Redirect HTTP → HTTPS | Every visitor connection is encrypted |
| TLS | Minimum TLS version = TLSv1.2_2021 | Blocks outdated, insecure protocol versions |
| Versioning | Enabled on the S3 bucket | Protects against accidental overwrite/delete of site files |
| Logging | S3 server access logging or CloudFront standard logs enabled to a separate logging bucket | Audit trail of who accessed what, when |
| MFA Delete (optional, advanced) | Enabled on the bucket | Extra protection against accidental/malicious deletion |

---

## 6. Deliverables Checklist

- [ ] Architecture diagram (the one above, or redraw in draw.io/Lucidchart for your portfolio)
- [ ] 6 console screenshots per Section 3
- [ ] Cost breakdown table (Section 4) — screenshot of AWS Pricing Calculator estimate too
- [ ] Security settings screenshot (bucket policy + block public access toggle)
- [ ] Live URL (optional, if you actually deploy it — even a free domain from Route 53/registrar makes this far more credible)

---

## 7. LinkedIn Post Draft

**Title:** Hosting a Secure Business Website on AWS Using S3 and CloudFront

**Post body:**

> Just wrapped up a hands-on AWS project: hosting a secure, low-latency static business website using S3, CloudFront, Route 53, and ACM.
>
> 🔹 The scenario: a small business (fictional client — NimbusCraft Interiors) needed a fast, HTTPS-secured site without managing any servers.
>
> 🔹 What I built:
> — S3 bucket (private, static website hosting)
> — CloudFront distribution with Origin Access Control — no direct public access to S3
> — Free SSL/TLS certificate via ACM, forced HTTPS redirect
> — Custom domain routing through Route 53
>
> 🔹 Result: ~$7/month estimated cost, global edge caching, and an A+ on security headers — all without a single EC2 instance.
>
> 🔹 Key lesson learned: ACM certificates for CloudFront must be requested in us-east-1, regardless of your bucket's region — an easy trap for beginners.
>
> Architecture diagram and full breakdown in the comments/portfolio link 👇
>
> #AWS #CloudComputing #S3 #CloudFront #DevOps #CloudSecurity

---

## 8. Notes for Your Portfolio README

When you write this up on GitHub/Notion, structure it as: **Problem → Architecture → Steps → Cost → Security → Result**. This mirrors how real cloud engineers document projects and is the exact structure hiring managers scan for.
