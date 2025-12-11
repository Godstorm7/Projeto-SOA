@echo off
echo Verificando status do Kafka...

echo.
echo 1. Verificando containers...
docker ps --filter "name=kafka" --format "table {{.Names}}\t{{.Status}}"

echo.
echo 2. Verificando saúde do Kafka...
docker inspect kafka --format "{{json .State.Health }}" | python -c "import json,sys; obj=json.load(sys.stdin); print(f'Status: {obj[\"Status\"]}')"

echo.
echo 3. Listando tópicos...
docker exec kafka kafka-topics --bootstrap-server localhost:29092 --list

echo.
echo 4. Verificando detalhes dos tópicos...
for /f "tokens=*" %%i in ('docker exec kafka kafka-topics --bootstrap-server localhost:29092 --list') do (
    echo Topico: %%i
    docker exec kafka kafka-topics --bootstrap-server localhost:29092 --topic %%i --describe
)

echo.
echo 5. Testando produção de mensagem...
docker exec kafka bash -c "echo '{\"test\": \"message\", \"timestamp\": $(date +%s)}' | kafka-console-producer --broker-list localhost:29092 --topic test-topic --property parse.key=true --property key.separator=: 2>/dev/null || echo 'Erro na produção'"

echo.
echo 6. Testando consumo de mensagem...
docker exec kafka timeout 5 kafka-console-consumer --bootstrap-server localhost:29092 --topic test-topic --from-beginning --max-messages 1 --timeout-ms 5000 2>/dev/null

if %errorlevel% equ 0 (
    echo Kafka está funcionando corretamente
) else (
    echo Kafka com problemas de consumo
)

echo.
echo Verificação do Kafka concluída!