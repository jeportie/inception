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

all: prepare up

prepare:
	mkdir -p ~/data/wordpress ~/data/mariadb

up: prepare
	docker-compose -f srcs/docker-compose.yml up -d --build

down:
	docker-compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf ~/data/wordpress ~/data/mariadb

re: fclean all
