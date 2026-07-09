export interface ApiMeta {
  traceId: string;
  timestamp: string;
}

export interface ApiSuccessResponse<T> {
  data: T;
  meta: ApiMeta;
  pagination?: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
  };
}

export interface ApiErrorDetail {
  field?: string;
  message: string;
}

export interface ApiErrorBody {
  code: string;
  message: string;
  details?: ApiErrorDetail[];
}

export interface ApiErrorResponse {
  error: ApiErrorBody;
  meta: ApiMeta;
}
