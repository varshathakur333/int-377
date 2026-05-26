ubuntu@ip-172-31-46-26:~$ cat /home/ubuntu/app/docker-compose.yml
services:
  weather-app:
    build: .
    container_name: weather-app
    restart: always
    ports:
      - "80:80"
    networks:
      - weather-net

  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:latest
    container_name: nginx-exporter
    restart: always
    command:
      - -nginx.scrape-uri=http://weather-app:80/nginx_status
    ports:
      - "9113:9113"
    depends_on:
      - weather-app
    networks:
      - weather-net

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: always
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($|/)'
    ports:
      - "9100:9100"
    networks:
      - weather-net

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: always
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    ports:
      - "9090:9090"
    depends_on:
      - nginx-exporter
      - node-exporter
    networks:
      - weather-net

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: always
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro
    depends_on:
      - prometheus
    networks:
      - weather-net


  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: always
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
    networks:
      - weather-net

networks:
  weather-net:
    driver: bridge

volumes:
  jenkins_home:
