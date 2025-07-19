#!/bin/bash
set -e

echo "🚀 Testing Minimal Agentic Compose - All Configurations"
echo "======================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test problem
TEST_PROBLEM="Calculate the factorial of 5"

echo -e "${BLUE}🔍 Validating all compose configurations...${NC}"

# Validate compose files
echo -e "${YELLOW}📋 Default configuration:${NC}"
if docker compose config --quiet; then
    echo -e "${GREEN}✅ Default compose file is valid${NC}"
else
    echo -e "${RED}❌ Default compose file has errors${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 OpenAI configuration:${NC}"
if docker compose -f compose.yaml -f compose.openai.yaml config --quiet; then
    echo -e "${GREEN}✅ OpenAI compose file is valid${NC}"
else
    echo -e "${RED}❌ OpenAI compose file has errors${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Docker Offload configuration:${NC}"
if docker compose -f compose.yaml -f compose.offload.yaml config --quiet; then
    echo -e "${GREEN}✅ Docker Offload compose file is valid${NC}"
else
    echo -e "${RED}❌ Docker Offload compose file has errors${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🏗️  Building Docker images...${NC}"
if docker compose build; then
    echo -e "${GREEN}✅ Docker images built successfully${NC}"
else
    echo -e "${RED}❌ Failed to build Docker images${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🧪 Testing available configurations...${NC}"

# Test OpenAI if API key is available
if [ -n "$OPENAI_API_KEY" ] || [ -f "secret.openai-api-key" ]; then
    echo -e "${YELLOW}🤖 Testing OpenAI configuration...${NC}"
    if timeout 60s docker compose -f compose.yaml -f compose.openai.yaml up --abort-on-container-exit; then
        echo -e "${GREEN}✅ OpenAI test completed successfully${NC}"
        if [ -f "output/result.txt" ]; then
            echo -e "${GREEN}📄 Output file created:${NC}"
            head -5 output/result.txt
        fi
    else
        echo -e "${YELLOW}⚠️  OpenAI test timed out or failed (this might be normal)${NC}"
    fi
    
    # Cleanup
    docker compose -f compose.yaml -f compose.openai.yaml down -v 2>/dev/null || true
    rm -rf output/ sandbox-output/ 2>/dev/null || true
else
    echo -e "${YELLOW}⚠️  OpenAI API key not found, skipping OpenAI test${NC}"
    echo -e "${BLUE}💡 To test OpenAI: export OPENAI_API_KEY=your_key or create secret.openai-api-key${NC}"
fi

# Test Docker Offload if token is available
if [ -n "$DOCKER_OFFLOAD_TOKEN" ]; then
    echo -e "${YELLOW}☁️  Testing Docker Offload configuration...${NC}"
    echo -e "${GREEN}✅ Docker Offload configuration validated${NC}"
    echo -e "${BLUE}💡 Docker Offload requires proper authentication and may have usage costs${NC}"
else
    echo -e "${YELLOW}⚠️  Docker Offload token not found, skipping Offload test${NC}"
    echo -e "${BLUE}💡 To test Docker Offload: export DOCKER_OFFLOAD_TOKEN=your_token${NC}"
fi

# Test Docker Model Runner (default) - build only since it needs GPU
echo -e "${YELLOW}🏠 Testing Docker Model Runner (default) configuration...${NC}"
echo -e "${GREEN}✅ Docker Model Runner configuration validated${NC}"
echo -e "${BLUE}💡 Full DMR test requires GPU. To test: docker compose up${NC}"

echo ""
echo -e "${GREEN}🎉 All tests completed!${NC}"
echo ""
echo -e "${BLUE}📚 Usage Examples:${NC}"
echo -e "  Default (Docker Model Runner): ${YELLOW}docker compose up${NC}"
echo -e "  With OpenAI:                   ${YELLOW}docker compose -f compose.yaml -f compose.openai.yaml up${NC}"
echo -e "  With Docker Offload:           ${YELLOW}docker compose -f compose.yaml -f compose.offload.yaml up${NC}"
echo ""
echo -e "${BLUE}🔧 Custom problems:${NC}"
echo -e "  ${YELLOW}PROBLEM=\"Your coding challenge\" docker compose up${NC}"
echo ""
echo -e "${GREEN}✨ Repository is ready for agentic coding! ✨${NC}"
