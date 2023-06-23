format-test-data:
	xmllint --format Tests/UnitTests/Test Data/_components/struct/PostQuery.xml

start-db-server:
	docker run --name mysql --rm -p 3306:3306 -eMYSQL_USER=wordpress -eMYSQL_PASSWORD=wordpress -eMYSQL_DATABASE=wordpress -eMYSQL_RANDOM_ROOT_PASSWORD=true -d mysql
	sleep 10
	docker exec -i mysql sh -c 'exec mysql -uwordpress -pwordpress' < db.sql
	docker run --rm -p 80:80 -e WORDPRESS_DB_HOST=host.docker.internal -e WORDPRESS_DB_USER=wordpress -e WORDPRESS_DB_PASSWORD=wordpress -e WORDPRESS_DB_NAME=wordpress  wordpress:6.2.2

dump-db:
	docker exec mysql sh -c 'exec mysqldump --databases wordpress -uwordpress -pwordpress' | tee db.sql
