import os
import requests
import operator

# --- Configuração ---
# O token é pego de um "secret" do GitHub Actions
GH_TOKEN = os.environ.get('GH_PAT') 
GH_OWNER = os.environ.get('GH_OWNER')
GH_REPO = os.environ.get('GH_REPO')
SVG_FILENAME = "repo-languages.svg"

# --- Validação ---
if not GH_TOKEN:
    raise ValueError("É necessário definir o secret GH_PAT no repositório.")

# --- 1. Buscar dados da API do GitHub ---
headers = {
    "Authorization": f"bearer {GH_TOKEN}"
}
url = f"https://api.github.com/repos/{GH_OWNER}/{GH_REPO}/languages"
response = requests.get(url, headers=headers)
response.raise_for_status()  # Lança um erro se a requisição falhar
languages_data = response.json()

# --- 2. Calcular o total e as porcentagens ---
total_bytes = sum(languages_data.values())
if total_bytes == 0:
    print("Nenhuma linguagem encontrada ou o repositório está vazio.")
    # Cria um SVG vazio ou com uma mensagem
    # (simplificado aqui, vamos parar a execução)
    exit()
    
sorted_languages = sorted(languages_data.items(), key=operator.itemgetter(1), reverse=True)

# --- 3. Gerar o conteúdo do SVG ---
# Cores para as barras (pode adicionar mais)
colors = ["#3498db", "#2ecc71", "#f1c40f", "#e74c3c", "#9b59b6", "#1abc9c"]

svg_content = """<svg width="300" height="{height}" xmlns="http://www.w3.org/2000/svg">
    <style>
        .lang-name {{ font: 600 12px 'Segoe UI', Ubuntu, Sans-Serif; fill: #333; }}
        .lang-percent {{ font: 400 11px 'Segoe UI', Ubuntu, Sans-Serif; fill: #555; }}
        .progress-bar {{ border-radius: 4px; }}
    </style>
    <rect width="100%" height="100%" fill="#f9f9f9" stroke="#e1e4e8" stroke-width="1" rx="6" ry="6"/>
    <g transform="translate(15, 20)">
"""

bar_y_pos = 0
for i, (lang, bytes_count) in enumerate(sorted_languages):
    percentage = (bytes_count / total_bytes) * 100
    color = colors[i % len(colors)]
    
    # Adiciona nome da linguagem e porcentagem
    svg_content += f"""
        <text x="0" y="{bar_y_pos + 12}" class="lang-name">{lang}</text>
        <text x="270" y="{bar_y_pos + 12}" text-anchor="end" class="lang-percent">{percentage:.1f}%</text>
    """
    
    # Adiciona a barra de progresso
    svg_content += f"""
        <rect x="0" y="{bar_y_pos + 18}" width="270" height="8" fill="#ddd" rx="4" ry="4" class="progress-bar"/>
        <rect x="0" y="{bar_y_pos + 18}" width="{2.7 * percentage}" height="8" fill="{color}" rx="4" ry="4" class="progress-bar"/>
    """
    
    bar_y_pos += 35 # Espaçamento para o próximo item

# Finaliza o SVG
svg_height = bar_y_pos + 30 # Altura dinâmica baseada no conteúdo - aumentado o espaçamento inferior
svg_content = svg_content.format(height=svg_height) # Insere a altura correta
svg_content += """
    </g>
</svg>"""

# --- 4. Salvar o arquivo SVG ---
with open(SVG_FILENAME, "w") as f:
    f.write(svg_content)

print(f"Arquivo '{SVG_FILENAME}' gerado com sucesso!")