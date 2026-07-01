# Hosting a Secure Static Business Website on AWS (S3 + CloudFront + Route 53 + ACM)

A hands-on AWS project: hosting a fast, secure, low-cost static business website using S3 for storage, CloudFront for global CDN delivery, ACM for free SSL/TLS, and Route 53 for DNS.

**Business scenario:** NimbusCraft Interiors, a small furniture & home-decor business, needed a fast-loading, HTTPS-secured website without managing servers or paying for a costly SSL certificate.

---

## Architecture

```
User Browser → Route 53 (DNS) → CloudFront (CDN + HTTPS) → S3 Bucket (Origin)
                                        ↑
                                 ACM SSL Certificate
```

| Layer | Service | Role |
|---|---|---|
| DNS | Route 53 | Maps custom domain to the CloudFront distribution |
| CDN / Edge | CloudFront | Caches content worldwide, terminates HTTPS |
| SSL/TLS | AWS Certificate Manager (ACM) | Free public certificate, auto-renewed |
| Storage / Origin | S3 (static website hosting) | Stores HTML/CSS/JS/images, kept private, accessed only via CloudFront |

See `/screenshots` for the diagram and console evidence, and `/aws-config` for the exact bucket policy and CloudFront settings used.

---

## Build steps

1. **S3 bucket** — created a private bucket, uploaded the site in `/website`, enabled static website hosting (index document `index.html`)
2. **ACM certificate** — requested a public SSL certificate in **us-east-1** (required for CloudFront regardless of bucket region), validated via DNS
3. **CloudFront distribution** — origin = S3 bucket via **Origin Access Control (OAC)**, viewer protocol policy = redirect HTTP to HTTPS, custom SSL cert attached
4. **S3 bucket policy** — scoped so only this specific CloudFront distribution can read objects (see `/aws-config/bucket-policy-example.json`)
5. **Route 53** — hosted zone created, Alias A record pointing the domain to the CloudFront distribution
6. **Verification** — confirmed HTTPS padlock, confirmed HTTP auto-redirects to HTTPS

Full step-by-step writeup with details: [`docs/case-study.md`](./docs/case-study.md)

---

## Cost estimate

Assuming ~10 GB storage, ~50 GB CloudFront transfer/month, ~2M requests/month:

| Service | Monthly cost (approx) |
|---|---|
| S3 storage + requests | ~$0.25 |
| CloudFront transfer + requests | ~$5.75 |
| ACM certificate | $0.00 (free) |
| Route 53 hosted zone + queries | ~$0.90 |
| **Total** | **~$6.90/month** |

Compared to typical shared hosting + paid SSL + CDN add-on (₹1,500–4,000/month), this setup is significantly cheaper while also being faster globally.

---

## Security configuration

- S3 bucket: **Block all public access = ON** (fully private)
- Access only via CloudFront **Origin Access Control (OAC)**
- Bucket policy scoped to one specific CloudFront distribution ARN
- Viewer protocol policy: **Redirect HTTP → HTTPS**
- Minimum TLS version: **TLSv1.2_2021**
- S3 versioning enabled (protects against accidental overwrite/delete)

---

## Tech / services used

`AWS S3` `AWS CloudFront` `AWS Certificate Manager (ACM)` `AWS Route 53` `HTML` `CSS`

---

## Repo structure

```
aws-static-website-hosting/
├── README.md                          → you are here
├── website/                           → static site source files (deploy this to S3)
│   ├── index.html
│   ├── about.html
│   ├── products.html
│   ├── gallery.html
│   ├── contact.html
│   └── style.css
├── aws-config/                        → reference configs used in this project
│   ├── bucket-policy-example.json
│   └── cloudfront-settings-notes.md
├── screenshots/                       → console evidence (add your own screenshots here)
│   └── README.md                      → checklist of what to capture
└── docs/
    └── case-study.md                  → full detailed writeup
```

---

## Live demo

`https://your-cloudfront-domain.cloudfront.net` *(replace once deployed)*

---

## Author notes

Built as part of a self-directed AWS learning series (Week 1, Project 1) to practice mapping a real business requirement to core AWS services.
