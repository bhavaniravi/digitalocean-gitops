FROM python:3.10-slim-buster

COPY app/requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install -r requirements.txt

COPY app /app



ENTRYPOINT ["python", "app.py"]