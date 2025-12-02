#############################
#        BUILD STAGE        #
#############################
FROM python:3.11-slim AS builder   

#  Environnement durci   
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Installer seulement ce qui est nécessaire pour compiler les dépendances
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Copier uniquement les dépendances
COPY requirements.txt .

# Installer les dépendances dans un dossier isolé, sans cache
RUN pip install --no-cache-dir --user -r requirements.txt


#############################
#       RUNTIME STAGE       #
#############################
FROM python:3.11-slim AS runtime

WORKDIR /app

# Créer un utilisateur non-root
RUN useradd --create-home --shell /usr/sbin/nologin appuser

# Copier seulement ce qui est nécessaire à l'exécution
COPY --from=builder --chown=appuser:appuser /root/.local /root/.local
COPY --chown=appuser:appuser . .

# Ajouter les binaires Python installés au PATH
ENV PATH="/root/.local/bin:${PATH}"

USER appuser

EXPOSE 4000

CMD ["python", "main.py"]
