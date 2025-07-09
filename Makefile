# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jeportie <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/18 14:57:53 by jeportie          #+#    #+#              #
#    Updated: 2025/06/18 14:58:00 by jeportie         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

DCLOC = srcs/docker-compose.yml
DC = docker-compose -f $(DCLOC)
ENV = srcs/.env

all: prepare build up

prepare: fix-perms
	mkdir -p ~/data/wordpress ~/data/mariadb

fix-perms:
	sudo chown -R 1000:1000 ~/data/wordpress ~/data/mariadb

build:
	$(DC) --env-file $(ENV) build

up: prepare
	$(DC) --env-file $(ENV) up -d

down:
	$(DC) --env-file $(ENV) down

clean: down
	docker system prune -af
	$(DC) --env-file $(ENV) down -v --rmi all --remove-orphans

fclean: clean
	sudo rm -rf ~/data/wordpress ~/data/mariadb

logs:
	$(DC) --env-file $(ENV) logs -f

re: clean all

.PHONY: all prepare up down clean fclean logs re
