export declare class HealthController {
    getRoot(): {
        status: string;
        service: string;
        docs: string;
    };
    getHealth(): {
        status: string;
        service: string;
    };
}
