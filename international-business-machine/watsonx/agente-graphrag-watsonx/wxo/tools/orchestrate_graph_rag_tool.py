"""Herramienta para realizar búsquedas Graph RAG en documentos."""

from graph_retriever.strategies import Eager
from ibm_watsonx_orchestrate.agent_builder.connections import (
    ConnectionType,
    ExpectedCredentials,
)
from ibm_watsonx_orchestrate.agent_builder.tools import ToolPermission, tool
from ibm_watsonx_orchestrate.run import connections
from langchain_astradb import AstraDBVectorStore
from langchain_graph_retriever import GraphRetriever
from langchain_ibm import WatsonxEmbeddings
from pydantic import BaseModel, Field


class RAGSearchResults(BaseModel):
    """Represents the search results."""

    context_data: str | None = Field(description="Context data for the question")
    document_titles: list[str] | None = Field(description="A list of document titles")


@tool(
    name="orchestrate_graph_rag_tool",
    permission=ToolPermission.READ_ONLY,
    expected_credentials=[
        ExpectedCredentials(app_id="astradb", type=ConnectionType.KEY_VALUE),
        ExpectedCredentials(app_id="watsonx", type=ConnectionType.KEY_VALUE),
    ],
)
def doc_search_graph_rag(question: str) -> RAGSearchResults:
    """Retrieve context data to help answer a question using Graph RAG."""
    astradb_conn = connections.key_value("astradb")
    watsonx_conn = connections.key_value("watsonx")
    astra_db_api_endpoint = astradb_conn["ASTRA_DB_API_ENDPOINT"]
    astra_db_application_token = astradb_conn["ASTRA_DB_APPLICATION_TOKEN"]
    watsonx_apikey = watsonx_conn["WATSONX_APIKEY"]
    watsonx_project_id = watsonx_conn["WATSONX_PROJECT_ID"]
    watsonx_url = watsonx_conn.get("WATSONX_URL", "https://eu-gb.ml.cloud.ibm.com")
    embeddings = WatsonxEmbeddings(
        model_id="ibm/granite-embedding-278m-multilingual",
        url=watsonx_url,  # type: ignore
        apikey=watsonx_apikey,
        project_id=watsonx_project_id,
    )
    collection = "wxo_docs"
    vectorstore = AstraDBVectorStore(
        embedding=embeddings,
        collection_name=collection,
        pre_delete_collection=False,
        api_endpoint=astra_db_api_endpoint,
        token=astra_db_application_token,
    )
    graph_retriever = GraphRetriever(
        store=vectorstore,
        edges=[("hyperlinks", "url")],
        strategy=Eager(k=6, start_k=5, max_depth=1),
    )
    query_results = graph_retriever.invoke(question)
    results_str = ""
    chunks_used = []
    for result in query_results:
        results_str += result.page_content
        results_str += "\n\n------------"
        chunks_used.append(result.metadata["id"])

    result = RAGSearchResults(context_data=results_str, document_titles=chunks_used)

    return result
