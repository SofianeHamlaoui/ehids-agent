TARGETS := kern/sec_socket_connect
TARGETS += kern/tcp_set_state
TARGETS += kern/dns_lookup
TARGETS += kern/udp_lookup
TARGETS += kern/java_exec
TARGETS += kern/proc

# Generate file name-scheme based on TARGETS
KERN_SOURCES = ${TARGETS:=_kern.c}
KERN_OBJECTS = ${KERN_SOURCES:.c=.o}

LLC ?= llc
CLANG ?= clang
EXTRA_CFLAGS ?= -O2 -mcpu=v1 -nostdinc

LINUXINCLUDE =  \
				-I/usr/include \
				-I/home/cfc4n/download/linux-5.11.0/include \
				-I/home/cfc4n/download/linux-5.11.0/tools/lib


all: $(KERN_OBJECTS) build
	@echo $(shell date)

.PHONY: clean

clean:
	rm -rf user/bytecode/*.d
	rm -rf user/bytecode/*.o
	rm -rf bin/ehids

$(KERN_OBJECTS): %.o: %.c
	$(CLANG) $(EXTRA_CFLAGS) \
		$(LINUXINCLUDE) \
		-target bpfel -c $< -o $(subst kern/,user/bytecode/,$@) \
		-fno-ident -fdebug-compilation-dir . -g -D__BPF_TARGET_MISSING="GCC error \"The eBPF is using target specific macros, please provide -target\"" \
		-MD -MP

build:
	go build -o bin/ehids .