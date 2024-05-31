FROM python:3.12-slim

RUN apt-get update && apt-get install -y nodejs npm

WORKDIR /usr/src/app

# Install Python dependencies
COPY requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements-dev.txt

# Copy package.json and package-lock.json (if present) to install npm dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Run Setup
RUN python setup.py install

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=example.settings

# Collect static files
RUN python example/manage.py collectstatic --noinput

# Expose port 8000 (Django's default port)
EXPOSE 8000

# Run migrations and start the Django development server
CMD ["sh", "-c", "python example/manage.py migrate && python example/manage.py createsuperuser && python example/manage.py runserver 0.0.0.0:8000"]
