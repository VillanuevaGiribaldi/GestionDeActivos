export type  apiResponse<T>= {
    message: string;
    data: T;
    error: string;
}