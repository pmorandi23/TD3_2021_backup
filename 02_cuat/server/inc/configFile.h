
// Defines
#define CANT_CONEX_MAX_DEFAULT 100
#define BACKLOG_DEFAULT 20
#define MUESTREO_SENSOR 2
#define CONFIG_PATH "./files/serverConfig.cfg"


// Prototipos de función
//void config_server_init(struct serverConfig *);
void leer_config_server(struct serverConfig *);
void apagar_server(struct serverConfig * );
