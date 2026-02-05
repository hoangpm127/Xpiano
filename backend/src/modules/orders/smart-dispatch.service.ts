import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FindNearestWarehousesDto } from './dto';
import { NearestWarehouseResponse } from './responses';
import { PianoStatus } from '@prisma/client';

@Injectable()
export class SmartDispatchService {
    constructor(private readonly prisma: PrismaService) { }

    /**
     * Smart Dispatch Algorithm
     * Find nearest warehouses using PostGIS ST_Distance
     */
    async findNearestWarehouses(
        dto: FindNearestWarehousesDto,
    ): Promise<NearestWarehouseResponse[]> {
        const { lat, lng, pianoType = 'any', radiusKm = 50 } = dto;

        // Use Prisma's raw query for PostGIS
        const warehouses: any[] = await this.prisma.$queryRaw`
      SELECT 
        w.id,
        w.name,
        w.address,
        w.district,
        w.city,
        w.phone,
        w.available_pianos,
        w.avg_rating,
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

        // For each warehouse, get available pianos
        const warehousesWithPianos = await Promise.all(
            warehouses.map(async (w) => {
                const pianos = await this.prisma.piano.findMany({
                    where: {
                        warehouseId: w.id,
                        status: PianoStatus.available,
                        ...(pianoType !== 'any' && { keysCount: parseInt(pianoType) }),
                    },
                    select: {
                        id: true,
                        brand: true,
                        model: true,
                        keysCount: true,
                        dailyRate: true,
                        monthlyRate: true,
                        images: true,
                        condition: true,
                        avgRating: true,
                    },
                    take: 5,
                });

                return {
                    id: w.id,
                    name: w.name,
                    address: w.address,
                    district: w.district,
                    city: w.city,
                    phone: w.phone,
                    distanceKm: parseFloat(Number(w.distance_km).toFixed(2)),
                    estimatedDeliveryHours: this.calculateDeliveryTime(w.distance_km),
                    avgRating: Number(w.avg_rating),
                    availablePianos: pianos.map((p) => ({
                        id: p.id,
                        brand: p.brand,
                        model: p.model,
                        keysCount: p.keysCount,
                        dailyRate: Number(p.dailyRate),
                        monthlyRate: p.monthlyRate ? Number(p.monthlyRate) : null,
                        images: p.images as string[],
                        condition: p.condition,
                        avgRating: Number(p.avgRating),
                    })),
                };
            }),
        );

        // Filter out warehouses with no matching pianos
        return warehousesWithPianos.filter((w) => w.availablePianos.length > 0);
    }

    /**
     * Calculate estimated delivery time based on distance
     * Formula: 30 mins base + 5 mins per km
     */
    private calculateDeliveryTime(distanceKm: number): number {
        const baseMinutes = 30;
        const minutesPerKm = 5;
        const totalMinutes = baseMinutes + distanceKm * minutesPerKm;
        return Math.ceil(totalMinutes / 60); // Convert to hours
    }
}
