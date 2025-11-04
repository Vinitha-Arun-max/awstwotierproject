### 🧩 `README.md`

```markdown
# 🌩️ Two-Tier AWS Infrastructure using Terraform

This project automates the deployment of a **highly available two-tier architecture** on AWS using **Terraform**.  
It provisions a **VPC**, **public/private subnets**, **EC2 Auto Scaling Group**, **Application Load Balancer (ALB)**, and **RDS** for the database layer.

---

## 🏗️ Architecture Overview

**Tier 1 (Web Tier):**
- Auto Scaling Group (EC2) behind an Application Load Balancer
- User data automatically installs and configures a simple web server
- ALB routes HTTP traffic to healthy EC2 instances

**Tier 2 (Database Tier):**
- Amazon RDS (MySQL) deployed in private subnets
- Security Groups restrict access to DB only from Web instances

**Networking:**
- Custom VPC with 2 public and 2 private subnets (for high availability)
- Internet Gateway for public subnets
- NAT Gateway for private subnets
- Route Tables and proper routing setup

---

## 🧰 Technologies Used
- **Terraform** — Infrastructure as Code (IaC)
- **AWS EC2** — Web server instances
- **AWS ALB (Application Load Balancer)** — Distributes traffic
- **AWS RDS (MySQL)** — Managed database
- **AWS Auto Scaling Group** — Dynamic scaling of web servers
- **AWS VPC / Subnets / Security Groups** — Networking and isolation

---

## 📁 Project Structure
```

two-tier-terraform/
├── main.tf                # Main Terraform configuration
├── variables.tf           # Input variables
├── outputs.tf             # Output values (ALB DNS, RDS endpoint)
├── provider.tf            # AWS provider configuration
├── user_data.sh           # EC2 initialization script
├── .gitignore             # Ignore Terraform state, secrets, etc.
└── README.md              # Project documentation

````

---

## ⚙️ Prerequisites

Before you start, ensure you have:

1. **Terraform** ≥ 1.5 installed  
   ```bash
   terraform -v
````

2. **AWS CLI** configured with valid credentials

   ```bash
   aws configure
   ```

3. **IAM user** with sufficient privileges (EC2, VPC, RDS, IAM, AutoScaling, ELB)

4. (Optional) A registered **Route 53 domain** (if you want a custom domain)

---

## 🚀 Deployment Steps

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/<your-username>/two-tier-terraform.git
cd two-tier-terraform
```

### 2️⃣ Initialize Terraform

```bash
terraform init
```

### 3️⃣ Validate Configuration

```bash
terraform validate
```

### 4️⃣ Preview Plan

```bash
terraform plan
```

### 5️⃣ Deploy Infrastructure

```bash
terraform apply -auto-approve
```

---

## 🌐 Accessing the Application

After deployment, Terraform outputs the ALB DNS name:

```bash
terraform output alb_dns_name
```

Open it in your browser:

```
http://<your-alb-dns-name>
```

You should see your default **Apache/Nginx web page**.

---

## 🧾 Verifying Components

| Layer       | What to Check                             | How to Verify                     |
| ----------- | ----------------------------------------- | --------------------------------- |
| **VPC**     | All subnets and routes created            | `terraform show`                  |
| **ALB**     | Accessible via browser or curl            | `curl http://<alb_dns>`           |
| **ASG**     | EC2 instances launched automatically      | AWS Console → Auto Scaling Groups |
| **RDS**     | Accessible only from EC2 (private subnet) | SSH into EC2 → connect via MySQL  |
| **Scaling** | Instances increase/decrease by load       | CloudWatch metrics                |

---

## 🧹 Teardown (Destroy)

To delete all resources:

```bash
terraform destroy -auto-approve
```

---

## 🧠 Notes

* If you **don’t have a domain**, the Route 53 configuration will be skipped automatically.
* All **state files** (`.tfstate`, `.terraform/`) are ignored in Git via `.gitignore`.
* You can customize the AMI, instance type, DB size, and subnets in `variables.tf`.

---

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👩‍💻 Author

**Vinitha Vijayakumar**
