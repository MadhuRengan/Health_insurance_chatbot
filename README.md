# Health Insurance RAG Chatbot
A retrieval-augmented generation (RAG) chatbot that answers health-insurance questions about coverage, exclusions, claims, premiums, and optional riders. The project is implemented in a Google Colab/Jupyter notebook and includes a Streamlit chat interface.
## How it works
1. Health-insurance knowledge-base entries are converted to text.
2. `all-MiniLM-L6-v2` creates an embedding for each text chunk.
3. FAISS stores the embeddings and retrieves entries related to the user's question.
4. LangChain passes the retrieved context and the question to Google Gemini.
5. A Streamlit interface displays the generated answer.
The chatbot prompt instructs the model to answer only from the supplied knowledge base and to avoid inventing policy details.
## Features
- Answers questions about hospitalization coverage and policy exclusions
- Explains cashless and reimbursement claim procedures
- Provides information about premiums, renewal, portability, and no-claim bonuses
- Covers optional benefits such as maternity and critical-illness riders
- Uses semantic search through Hugging Face embeddings and FAISS
- Includes a simple Streamlit web interface
- Provides a fallback response when the knowledge base does not contain an answer
## Technology stack
- Python
- Google Colab / Jupyter Notebook
- Google Gemini through `langchain-google-genai`
- LangChain
- Hugging Face `all-MiniLM-L6-v2` embeddings
- FAISS
- Streamlit
- ngrok or LocalTunnel for exposing the Colab app
## Repository structure
```text
Health_insurance_chatbot/
├── Insurance_chatbot.ipynb  # RAG pipeline, sample query, and Streamlit app
└── README.md                 # Project documentation
```
> The notebook initially loads `/content/knowledge_base (1).json`, but that file is not currently included in the repository. A later notebook cell contains an embedded sample knowledge base for the generated Streamlit app.
## Prerequisites
- A Google account with access to Google Colab, or Python 3.10+ with Jupyter installed
- A Google Gemini API key
- Internet access on the first run to download the embedding model
- An ngrok account only if you choose the ngrok option
## Run in Google Colab
1. Open `Insurance_chatbot.ipynb` in Google Colab.
2. Add your Gemini API key to **Colab secrets** using the name `api`.
3. If you want to run the first RAG workflow, upload the missing knowledge-base file as:
   ```text
   /content/knowledge_base (1).json
   ```
4. Run the notebook cells in order.
5. To launch the Streamlit interface, run the cell that creates `app.py`, followed by either the ngrok or LocalTunnel launch cell.
The notebook includes this secure pattern for loading the Gemini key:
```python
from google.colab import userdata
GOOGLE_API_KEY = userdata.get("api")
```
## Run locally
The repository currently stores the application inside the notebook rather than as a standalone `app.py`. To run it locally:
1. Clone the repository:
   ```bash
   git clone https://github.com/MadhuRengan/Health_insurance_chatbot.git
   cd Health_insurance_chatbot
   ```
2. Create and activate a virtual environment:
   ```bash
   python -m venv .venv
   ```
   On Windows:
   ```powershell
   .venv\Scripts\Activate.ps1
   ```
   On macOS or Linux:
   ```bash
   source .venv/bin/activate
   ```
3. Install the libraries used by the notebook:
   ```bash
   pip install jupyter streamlit faiss-cpu sentence-transformers \
     langchain langchain-core langchain-community langchain-classic \
     langchain-google-genai langchain-text-splitters pyngrok
   ```
4. Start Jupyter and open the notebook:
   ```bash
   jupyter notebook Insurance_chatbot.ipynb
   ```
Some cells use Colab-specific commands and paths. Replace `google.colab.userdata` with an environment variable and update `/content/...` paths when running locally.
For example:
```python
import os
GOOGLE_API_KEY = os.environ["GOOGLE_API_KEY"]
