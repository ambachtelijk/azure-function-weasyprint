import logging
import azure.functions as func
from weasyprint import HTML


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # name = req.params.get('name')
    pdf = HTML(string=req.get_body().decode('utf-8')).write_pdf()

    return func.HttpResponse(pdf)
