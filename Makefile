SRCS := 01/main.pas \
		02/main.pas \
		03/main.pas \
		04/main.pas \
		05/main.pas \
		06/main.pas

BINS := $(SRCS:.pas=)

.PHONY: all
all: $(BINS)

%: %.pas
	fpc $< -XX -gl