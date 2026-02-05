import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);

    // Global prefix
    app.setGlobalPrefix(process.env.API_PREFIX || 'api/v1');

    // Validation
    app.useGlobalPipes(
        new ValidationPipe({
            whitelist: true,
            forbidNonWhitelisted: true,
            transform: true,
            transformOptions: {
                enableImplicitConversion: true,
            },
        }),
    );

    // CORS
    app.enableCors({
        origin: process.env.CORS_ORIGIN?.split(',') || '*',
        credentials: true,
    });

    // Swagger Documentation
    const config = new DocumentBuilder()
        .setTitle('Xpiano API')
        .setDescription('O2O Piano Rental + EdTech Platform API')
        .setVersion('1.0')
        .addTag('auth', 'Authentication endpoints')
        .addTag('users', 'User management')
        .addTag('orders', 'Piano rental orders')
        .addTag('warehouses', 'Warehouse management')
        .addTag('affiliate', 'Affiliate program')
        .addTag('classroom', 'Online classroom')
        .addTag('wallet', 'Wallet & transactions')
        .addBearerAuth()
        .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);

    const port = process.env.PORT || 3000;
    await app.listen(port);

    console.log(`
  ╔═══════════════════════════════════════════╗
  ║                                           ║
  ║    🎹 XPIANO API SERVER STARTED 🎹       ║
  ║                                           ║
  ║    Environment: ${process.env.NODE_ENV?.padEnd(27) || 'development'.padEnd(27)}║
  ║    Port: ${String(port).padEnd(32)}║
  ║    API Docs: http://localhost:${port}/api/docs ║
  ║                                           ║
  ╚═══════════════════════════════════════════╝
  `);
}

bootstrap();
