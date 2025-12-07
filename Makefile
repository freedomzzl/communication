CXX = g++
CXXFLAGS = -O3 -march=native -funroll-loops -flto -pthread -std=c++14
LIBS = /usr/local/lib/libcryptopp.a -lpthread -lm

# 客户端需要的所有.cpp文件
CLIENT_CPP = client.cpp ringoram.cpp block.cpp bucket.cpp \
             param.cpp CryptoUtil.cpp Vocabulary.cpp Vector.cpp \
             Node.cpp InvertedIndex.cpp Document.cpp MBR.cpp \
             NodeSerializer.cpp Query.cpp RingoramStorage.cpp IRTree.cpp

# 服务器需要的所有.cpp文件
SERVER_CPP = storage_server.cpp block.cpp bucket.cpp \
             ServerStorage.cpp param.cpp CryptoUtil.cpp

# 默认编译所有
all: client server

# 编译客户端（生成client可执行文件）
client: $(CLIENT_CPP)
	$(CXX) $(CXXFLAGS) -o client $^ $(LIBS)

# 编译服务器（生成server可执行文件）
server: $(SERVER_CPP)
	$(CXX) $(CXXFLAGS) -o server $^ $(LIBS) -lboost_system

# 清理
clean:
	rm -f client server *.o

run_test: client server
	@echo "Starting server in background..."
	@./server &
	@SERVER_PID=$$!; \
	sleep 2; \
	echo "Starting client..."; \
	./client 127.0.0.1 12345; \
	echo "Stopping server..."; \
	kill $$SERVER_PID 2>/dev/null || true

# 重新编译
rebuild: clean all

# 显示帮助
help:
	@echo "可用命令:"
	@echo "  make all        - 编译客户端和服务器"
	@echo "  make client     - 编译客户端"
	@echo "  make server     - 编译服务器"
	@echo "  make clean      - 清理编译文件"
	@echo "  make rebuild    - 重新编译"
	@echo "  make run_test   - 运行客户端测试"
	@echo "  make run_server - 运行服务器"
	@echo "  make help       - 显示此帮助"

.PHONY: all clean run_test run_server rebuild help
