plugins {
    id("java")
}

group = "org.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(platform("org.junit:junit-bom:5.10.0"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    // https://mvnrepository.com/artifact/org.apache.kafka/kafka
//    implementation ("ch.qos.logback:logback-classic:1.2.3")
    implementation ("org.apache.kafka:kafka-clients:3.0.0")
//    implementation ("org.apache.kafka:kafka-streams:3.0.0")
//    implementation ("org.apache.kafka:kafka_2.13:3.0.0")
}

tasks.test {
    useJUnitPlatform()
}