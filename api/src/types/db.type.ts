// types.ts

export interface User {
    id: string;
    name: string;
    username: string;
    email?: string;
    role: 'admin' | 'editor';
    last_login?: string; // ISO timestamp
    created_at: string; // ISO timestamp
    updated_at: string; // ISO timestamp
}

export interface Post {
    id: string;
    title: string;
    slug: string;
    body: string; // HTML
    description?: string;
    cover_image?: string; // URL
    keywords?: string; // Coma-separated
    created_by: string; // User ID
    status: 'draft' | 'published';
    views: number;
    created_at: string; // ISO timestamp
    updated_at: string; // ISO timestamp
}

export interface Media {
    id: string;
    original_name: string;
    stored_name: string;
    type: 'image' | 'video';
    size: number; // bytes
    width?: number;
    height?: number;
    url: string; // URL completo
    uploaded_by: string; // User ID
    created_at: string; // ISO timestamp
    updated_at: string; // ISO timestamp
}
