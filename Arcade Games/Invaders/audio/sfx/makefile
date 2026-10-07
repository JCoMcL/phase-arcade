default: $(addprefix crushed/, $(wildcard *.wav))

crushed/%.wav: %.wav
	$(MAKE) crushed-8/$<
	$(MAKE) crushed-16/$<
	$(MAKE) crushed-32/$<
	$(MAKE) crushed-64/$<

crushed-8/%.wav: %.wav
	mkdir -p crushed-8
	ffmpeg -i $< -af 'acrusher=bits=64:samples=8' $@

crushed-16/%.wav: %.wav
	mkdir -p crushed-16
	ffmpeg -i $< -af 'acrusher=bits=64:samples=16' $@

crushed-32/%.wav: %.wav
	mkdir -p crushed-32
	ffmpeg -i $< -af 'acrusher=bits=64:samples=32' $@

crushed-64/%.wav: %.wav
	mkdir -p crushed-64
	ffmpeg -i $< -af 'acrusher=bits=64:samples=64' $@

.PHONY: clean
clean:
	rm -rf crushed-*


