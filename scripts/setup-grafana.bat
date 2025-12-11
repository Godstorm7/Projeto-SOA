@echo off
echo Configurando Grafana automaticamente...

echo.
echo 1. Aguardando Grafana ficar disponivel...
:check_grafana
curl -s -o nul -w "%%{http_code}" http://localhost:3000/api/health
if %errorlevel% neq 0 (
    echo Grafana ainda nao esta pronto, aguardando...
    timeout /t 5 /nobreak >nul
    goto :check_grafana
)
echo Grafana esta respondendo

echo.
echo 2. Configurando datasource do Prometheus...
curl -s -X POST "http://localhost:3000/api/datasources" ^
    -H "Content-Type: application/json" ^
    -u admin:admin ^
    -d "{\"name\":\"Prometheus\",\"type\":\"prometheus\",\"access\":\"proxy\",\"url\":\"http://prometheus:9090\",\"isDefault\":true,\"jsonData\":{\"timeInterval\":\"15s\",\"queryTimeout\":\"60s\"}}"

if %errorlevel% equ 0 (
    echo Datasource Prometheus configurado com sucesso!
) else (
    echo Datasource ja existe ou erro ao configurar
)

echo.
echo 3. Importando dashboard padrao...
curl -s -X POST "http://localhost:3000/api/dashboards/db" ^
    -H "Content-Type: application/json" ^
    -u admin:admin ^
    -d "{\"dashboard\":{\"id\":null,\"title\":\"SOA Architecture Monitoring\",\"tags\":[\"soa\",\"monitoring\"],\"timezone\":\"browser\",\"panels\":[{\"id\":1,\"title\":\"HTTP Requests Total\",\"type\":\"stat\",\"targets\":[{\"expr\":\"sum(requests_total)\",\"legendFormat\":\"Total Requests\",\"refId\":\"A\"}],\"gridPos\":{\"h\":8,\"w\":12,\"x\":0,\"y\":0}},{\"id\":2,\"title\":\"Request Latency\",\"type\":\"timeseries\",\"targets\":[{\"expr\":\"rate(request_latency_seconds_sum[5m]) / rate(request_latency_seconds_count[5m])\",\"legendFormat\":\"Avg Latency\",\"refId\":\"A\"}],\"gridPos\":{\"h\":8,\"w\":12,\"x\":12,\"y\":0}},{\"id\":3,\"title\":\"User Registrations\",\"type\":\"stat\",\"targets\":[{\"expr\":\"user_registrations_total\",\"legendFormat\":\"Registrations\",\"refId\":\"A\"}],\"gridPos\":{\"h\":8,\"w\":8,\"x\":0,\"y\":8}},{\"id\":4,\"title\":\"Post Creations\",\"type\":\"stat\",\"targets\":[{\"expr\":\"post_creations_total\",\"legendFormat\":\"Posts Created\",\"refId\":\"A\"}],\"gridPos\":{\"h\":8,\"w\":8,\"x\":8,\"y\":8}},{\"id\":5,\"title\":\"Service Health\",\"type\":\"stat\",\"targets\":[{\"expr\":\"up{job=~\\\"api-gateway|usuarios-service|posts-service\\\"}\",\"legendFormat\":\"{{job}}\",\"refId\":\"A\"}],\"gridPos\":{\"h\":8,\"w\":8,\"x\":16,\"y\":8}}],\"time\":{\"from\":\"now-1h\",\"to\":\"now\"},\"refresh\":\"10s\",\"schemaVersion\":35,\"version\":1},\"folderId\":0,\"overwrite\":true}"

if %errorlevel% equ 0 (
    echo Dashboard SOA Architecture importado com sucesso!
) else (
    echo Erro ao importar dashboard
)

echo.
echo 4. Configuracao do Grafana concluida!
echo.
echo Acesse: http://localhost:3000
echo Usuario: admin
echo Senha: admin
echo.