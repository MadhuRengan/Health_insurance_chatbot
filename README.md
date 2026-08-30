# Health Insurance RAG Chatbot
 
A Streamlit retrieval-augmented generation (RAG) application that answers health-insurance questions from a local knowledge base. It uses Hugging Face embeddings and FAISS for retrieval, then sends the retrieved context to Google Gemini through LangChain.
 
## Features
 
- Answers questions about coverage, exclusions, claims, premiums, and riders
- Retrieves relevant policy information with `all-MiniLM-L6-v2` embeddings and FAISS
- Instructs Gemini to answer only from the supplied knowledge base
- Provides a browser-based Streamlit interface
- Supports local Python execution and Docker deployment
- Includes a health-check endpoint suitable for Docker and an AWS Application Load Balancer
 
## Architecture
 
```text
User question
    |
    v
Streamlit UI
    |
    v
Hugging Face embedding -> FAISS similarity search
    |                         |
    +------ retrieved context-+
                |
                v
          Google Gemini
                |
                v
        Grounded response
```
 
## Repository structure
 
```text
Health_insurance_chatbot/
|-- app.py                    # Streamlit application and RAG pipeline
|-- data/
|   `-- knowledge_base.json   # Health-insurance knowledge base
|-- Dockerfile                # Production-oriented container definition
|-- requirements.txt          # Pinned Python dependencies
|-- .dockerignore             # Files excluded from the Docker build context
|-- .env.example              # Safe configuration template
`-- README.md                 # Project documentation
```
 
## Prerequisites
 
- Python 3.10 or later; Python 3.12 is used by the Docker image
- A Google Gemini API key
- Docker, if you want to run the container
- Internet access on the first run to download `all-MiniLM-L6-v2`
 
## Required configuration change
 
The current `app.py` in the repository contains a placeholder API key. Replace the hardcoded configuration with environment-based configuration before running or deploying it.
 
Add these imports near the top of `app.py`:
 
```python
import os
from dotenv import load_dotenv
 
load_dotenv()
```
 
Replace the hardcoded API-key and model block with:
 
```python
GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
GOOGLE_MODEL = os.environ.get("GOOGLE_MODEL", "gemini-3.5-flash")
EMBEDDING_MODEL = os.environ.get("EMBEDDING_MODEL", "all-MiniLM-L6-v2")
 
if not GOOGLE_API_KEY:
    raise RuntimeError("GOOGLE_API_KEY is not configured")
 
embeddings = HuggingFaceEmbeddings(model_name=EMBEDDING_MODEL)
 
llm = ChatGoogleGenerativeAI(
    model=GOOGLE_MODEL,
    temperature=0.5,
    google_api_key=GOOGLE_API_KEY,
)
```
 
Remove the earlier duplicate `embeddings = HuggingFaceEmbeddings(...)` assignment so the vector store is constructed with the environment-configured embedding model.
 
## Run locally with Python
 
1. Clone the repository and enter it:
 
   ```bash
   git clone https://github.com/MadhuRengan/Health_insurance_chatbot.git
   cd Health_insurance_chatbot
   ```
 
2. Create a virtual environment:
 
   ```bash
   python -m venv .venv
   ```
 
3. Activate it.
 
   Windows PowerShell:
 
   ```powershell
   .venv\Scripts\Activate.ps1
   ```
 
   macOS or Linux:
 
   ```bash
   source .venv/bin/activate
   ```
 
4. Install the pinned dependencies:
 
   ```bash
   python -m pip install --upgrade pip
   python -m pip install -r requirements.txt
   ```
 
5. Create local configuration:
 
   Windows PowerShell:
 
   ```powershell
   Copy-Item .env.example .env
   ```
 
   macOS or Linux:
 
   ```bash
   cp .env.example .env
   ```
 
6. Put the real Gemini API key in `.env`, then start the app:
 
   ```bash
   streamlit run app.py
   ```
 
7. Open `http://localhost:8501`.
 
## Run with Docker
 
1. Create `.env` from `.env.example` and supply the real Gemini key.
 
2. Build the image:
 
   ```bash
   docker build -t health-insurance-chatbot:local .
   ```
 
3. Run it:
 
   ```bash
   docker run --rm \
     --name health-insurance-chatbot \
     --env-file .env \
     -p 8501:8501 \
     health-insurance-chatbot:local
   ```
 
   PowerShell equivalent:
 
   ```powershell
   docker run --rm --name health-insurance-chatbot --env-file .env -p 8501:8501 health-insurance-chatbot:local
   ```
 
4. Open `http://localhost:8501`.
 
Check container health with:
 
```bash
docker inspect --format='{{json .State.Health}}' health-insurance-chatbot
```
 
## Deploy on Amazon EC2
 
A practical production flow is:
 
```text
GitHub -> Docker build -> Amazon ECR -> EC2 Docker host -> ALB/HTTPS
```
 
1. Rotate any API or tunnel credentials that were previously committed to the public repository.
2. Build and test the image locally.
3. Push the image to a private Amazon ECR repository.
4. Launch an Amazon Linux 2023 EC2 instance with an IAM instance role.
5. Grant the role only the ECR pull and secret-read permissions it needs.
6. Install Docker and pull the image from ECR.
7. Store the Gemini key in AWS Secrets Manager; do not bake it into the image or EC2 user data.
8. Run the container with a restart policy:
 
   ```bash
   docker run -d \
     --name health-insurance-chatbot \
     --restart unless-stopped \
     -p 8501:8501 \
     --env-file /opt/health-insurance-chatbot/app.env \
     ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/health-insurance-chatbot:VERSION
   ```
 
9. Put an Application Load Balancer in front of EC2, terminate HTTPS with an ACM certificate, and configure its target-group health check as `/_stcore/health`.
10. Allow EC2 port `8501` only from the load balancer security group. Prefer AWS Systems Manager Session Manager instead of exposing SSH port `22`.
 
For stronger secret handling, change the application to retrieve the Gemini key directly from AWS Secrets Manager using the EC2 instance role rather than storing it in an environment file.
 
## Example questions
 
- What does hospitalization coverage include?
- What is the waiting period for a pre-existing disease?
- How do I submit a cashless claim?
- Which documents are needed for reimbursement?
- How is the premium calculated?
- Is maternity coverage available?
 
## Known limitations
 
- The knowledge base contains example information rather than the complete wording of a live policy.
- The app rebuilds its embeddings and FAISS index when the Streamlit process starts.
- `langchain-community` and the `RetrievalQA` implementation used by this project are legacy dependencies and should be migrated in a future refactor.
- The project has no automated retrieval-quality or grounded-answer tests.
- It does not authenticate users, calculate personalized premiums, or access live claim data.
 
## Disclaimer
 
This project is an educational demonstration. It does not provide medical, legal, financial, or insurance advice. Always verify information against the official policy wording and consult the insurer or a licensed insurance professional.
 
## Author
 
[MadhuRengan](https://github.com/MadhuRengan)
