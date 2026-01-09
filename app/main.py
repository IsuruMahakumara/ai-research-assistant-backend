import uvicorn
from fastapi import FastAPI


from app.core.logger import setup_logging, get_logger, LOG_FILE
from app.schemas.chat import ChatRequest, ChatResponse
from app.llm import chat_model

setup_logging()
logger = get_logger(__name__)

app = FastAPI(title="AI Research Assistant")

logger.info(f"Log file location: {LOG_FILE.resolve()}")


@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    """
    Chat endpoint for user queries.

    Future: retrieval over static KB, LLM inference, response generation.
    """
    logger.info(f"Request: query={request.query!r}, top_k={request.top_k}")

    response = chat_model.invoke(request.query)

    final_response = {
        "query": request.query,
        "answer": response.content,
        "sources": []  # Pass an empty list for now until you add RAG
    }


    logger.info(f"Response: query={response}")

    return final_response


if __name__ == "__main__":
    # Get port from environment, default to 8080
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
