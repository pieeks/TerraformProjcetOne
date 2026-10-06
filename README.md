# TerraformProjectOne

Terraform-Setup für AWS in **eu-central-1 (Frankfurt)**: VPC, EC2 (Amazon Linux 2023) und RDS PostgreSQL — für Lern- und Testumgebungen mit geringen Kosten.

## Architektur

- **VPC** `10.0.0.0/16`
- **Public Subnet** — EC2 mit öffentlicher IP (SSH vom eigenen PC)
- **Private Subnets** (2 Availability Zones) — RDS PostgreSQL (nur von EC2 erreichbar)
- **Kein NAT Gateway** — spart laufende Kosten

```
Dein PC ──SSH──► EC2 (t3.micro) ──5432──► RDS (db.t3.micro, PostgreSQL 16)
```

## Voraussetzungen

| Tool | Zweck |
|------|--------|
| [Terraform](https://www.terraform.io/downloads) ≥ 1.x | Infrastruktur deployen |
| [AWS CLI](https://aws.amazon.com/cli/) (optional) | Credentials / Debugging |
| AWS Account | Mit konfigurierten Zugangsdaten |
| SSH-Key-Paar | Für EC2-Zugriff |

### AWS-Credentials

Lokal z. B. via:

```bash
aws configure
```

Oder Umgebungsvariablen `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` und `AWS_DEFAULT_REGION=eu-central-1`.

## Projektstruktur

| Datei | Inhalt |
|-------|--------|
| `main.tf` | Provider, VPC |
| `network.tf` | Internet Gateway, Subnets, Route Tables |
| `ec2.tf` | Key Pair, Security Group, EC2 |
| `rds.tf` | RDS PostgreSQL, DB Subnet Group |
| `variables.tf` | Konfigurierbare Variablen |
| `outputs.tf` | IP, RDS-Endpoint, SSH-Hinweise |
| `terraform.tfvars` | **Lokal anlegen**, nicht in Git (Secrets) |

## Ersteinrichtung

### 1. SSH-Key erzeugen (falls noch nicht vorhanden)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/aws-test -N ""
```

### 2. `terraform.tfvars` anlegen

Datei im Projektroot erstellen (wird durch `.gitignore` nicht committed):

```hcl
db_password      = "DeinSicheresPasswort123"
ssh_public_key   = "ssh-ed25519 AAAA... dein-user@host"
ssh_allowed_cidr = "DEINE.OEFFENTLICHE.IPV4/32"
```

- In `.tfvars` **nur doppelte Anführungszeichen** `"` verwenden (keine `'`)
- Öffentliche IPv4 ermitteln: `curl -4 ifconfig.me`
- `ssh_public_key`: Inhalt von `~/.ssh/aws-test.pub`

### 3. Terraform initialisieren

```bash
terraform init
```

## Deployen

```bash
terraform plan    # Vorschau — nichts wird in AWS geändert
terraform apply   # Mit yes bestätigen
```

**Dauer:** EC2 ca. 1–2 Minuten, RDS oft **5–10 Minuten**.

### Outputs

```bash
terraform output
terraform output ec2_public_ip
terraform output rds_address
```

## EC2 per SSH

```bash
ssh -i ~/.ssh/aws-test ec2-user@<EC2_PUBLIC_IP>
```

Beim ersten Mal Host-Key mit **`yes`** bestätigen.

- User: **`ec2-user`** (Amazon Linux 2023)
- Private Key: `~/.ssh/aws-test` (nicht die `.pub`-Datei)

## RDS von der EC2 testen

Auf der EC2-Instanz:

```bash
sudo dnf install -y postgresql15
psql -h <RDS_ADDRESS> -U postgres -d testdb
```

Passwort: Wert aus `terraform.tfvars` (`db_password`).

RDS ist **nicht** öffentlich erreichbar — nur von der EC2-Instanz im gleichen VPC.

## Aufräumen (Kosten stoppen)

```bash
terraform plan -destroy   # optional: Vorschau
terraform destroy
```

Löscht alle von Terraform verwalteten Ressourcen (EC2, RDS, VPC, …). Die `.tf`-Dateien und lokale `terraform.tfvars` bleiben erhalten; ein erneutes `terraform apply` erstellt die Infrastruktur wieder.

## Übersicht deployed / laufend

```bash
terraform state list
terraform output
```

In der AWS Console: Region **Frankfurt (eu-central-1)** wählen und EC2, RDS sowie VPC prüfen.

## Kostenhinweis (ca.)

| Szenario | ~Kosten |
|----------|---------|
| AWS Free Tier (innerhalb der Limits) | ~0 €/h |
| Ohne Free Tier (`t3.micro` + `db.t3.micro`) | ~0,03 €/h |

Nach erfolgreichem `terraform destroy` entstehen **keine** Compute-Kosten mehr für diese Ressourcen.

## Sicherheit

- `ssh_allowed_cidr` auf die eigene IP setzen (`x.x.x.x/32`), nicht dauerhaft `0.0.0.0/0`
- `terraform.tfvars`, `terraform.tfstate` und `.terraform/` **nicht** committen
- RDS-Passwort nur lokal in `terraform.tfvars` oder via `-var`

## Typische Fehler

| Problem | Lösung |
|---------|--------|
| `Invalid character` in `.tfvars` | Doppelte Anführungszeichen `"` nutzen |
| Ungültige CIDR bei SSH | Gültige IPv4 mit `/32`, z. B. `93.211.32.207/32` |
| RDS Engine Version | In `eu-central-1` ggf. `preferred_versions` in `rds.tf` anpassen |
| SSH timeout | Security Group / geänderte Heim-IP in `ssh_allowed_cidr` prüfen |
| `Host key verification failed` | Bei erster Verbindung exakt `yes` eingeben |

## Lizenz

Privates Lern- und Testprojekt.
