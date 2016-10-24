root = $(realpath $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))

export TIEFVISION_HOME = $(root)

h2:
	@touch $(root)/src/h2/tiefvision.mv.db

	docker build -t paucarre/tiefvision-db $(root)/src/h2
	docker run -it --rm -p 8082:8082 -p 9092:9092 -v $(root)/src/h2/tiefvision.mv.db:/root/tiefvision.mv.db paucarre/tiefvision-db

web:
	cd $(root)/src/scala/tiefvision-web && \
	sbt run

.PHONY: h2 web
