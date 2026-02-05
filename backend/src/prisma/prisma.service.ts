import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService
    extends PrismaClient
    implements OnModuleInit, OnModuleDestroy {
    constructor() {
        super({
            log: ['query', 'info', 'warn', 'error'],
        });
    }

    async onModuleInit() {
        await this.$connect();
        console.log('✅ Database connected');
    }

    async onModuleDestroy() {
        await this.$disconnect();
        console.log('❌ Database disconnected');
    }

    /**
     * Execute raw SQL for PostGIS queries
     */
    async findNearestWarehouses(lat: number, lng: number, radiusKm: number = 50) {
        return this.$queryRaw`
      SELECT 
        w.id,
        w.name,
        w.address,
        w.available_pianos,
        ST_Distance(
          ST_SetSRID(ST_MakePoint(w.lng, w.lat), 4326)::geography,
          ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography
        ) / 1000 as distance_km
      FROM warehouses w
      WHERE w.is_active = true
      AND w.available_pianos > 0
      AND ST_DWithin(
        ST_SetSRID(ST_MakePoint(w.lng, w.lat), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography,
        ${radiusKm * 1000}
      )
      ORDER BY distance_km ASC
      LIMIT 10
    `;
    }

    /**
     * Clean transaction wrapper
     */
    async executeTransaction<T>(
        fn: (tx: Omit<PrismaClient, '$connect' | '$disconnect' | '$on' | '$transaction' | '$use'>) => Promise<T>,
    ): Promise<T> {
        return this.$transaction(fn);
    }
}
