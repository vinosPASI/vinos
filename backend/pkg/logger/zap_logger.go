package logger

import (
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var log *zap.SugaredLogger

// Init inicializa el logger global con el nivel especificado ("debug", "info", "warn", "error").
func Init(level string) {
	config := zap.NewProductionConfig()
	config.EncoderConfig.TimeKey = "timestamp"
	config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder

	switch level {
	case "debug":
		config.Level = zap.NewAtomicLevelAt(zap.DebugLevel)
	case "warn":
		config.Level = zap.NewAtomicLevelAt(zap.WarnLevel)
	case "error":
		config.Level = zap.NewAtomicLevelAt(zap.ErrorLevel)
	default:
		config.Level = zap.NewAtomicLevelAt(zap.InfoLevel)
	}

	l, _ := config.Build()
	log = l.Sugar()
}

// Get retorna la instancia global del logger. Inicializa con nivel "info" si no fue inicializado.
func Get() *zap.SugaredLogger {
	if log == nil {
		Init("info")
	}
	return log
}

// Info registra un mensaje informativo con pares clave-valor opcionales.
func Info(msg string, keysAndValues ...interface{}) {
	Get().Infow(msg, keysAndValues...)
}

// Error registra un mensaje de error con pares clave-valor opcionales.
func Error(msg string, keysAndValues ...interface{}) {
	Get().Errorw(msg, keysAndValues...)
}

// Fatal registra un mensaje fatal y termina el proceso.
func Fatal(msg string, keysAndValues ...interface{}) {
	Get().Fatalw(msg, keysAndValues...)
}

// Debug registra un mensaje de depuración con pares clave-valor opcionales.
func Debug(msg string, keysAndValues ...interface{}) {
	Get().Debugw(msg, keysAndValues...)
}

// Sync vacía los buffers del logger. Debe llamarse con defer en main().
func Sync() {
	if log != nil {
		_ = log.Sync()
	}
}
