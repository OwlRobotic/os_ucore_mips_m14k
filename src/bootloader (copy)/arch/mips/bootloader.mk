BOOTSECT   := $(T_OBJ)/loader.o

all: $(BOOTSECT)

$(BOOTSECT): arch/${ARCH}/boot.S
	${V}mkdir $(T_OBJ)
	$(CC) -O3 -g -EL -c -msoft-float -march=m14kec -msoft-float -o $(T_OBJ)/loader.o $^


$(T_OBJ)/loader.o:mips/m32c0.h mips/regdef.h

