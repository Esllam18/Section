-- ============================================================
-- SECTION APP — COMPLETE DATABASE SCHEMA
-- Run this entire block in: Supabase Dashboard → SQL Editor
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUMS
CREATE TYPE faculty_type AS ENUM ('medicine','dentistry','pharmacy','nursing','physical_therapy','health_sciences','medical_technology','biomedical');
CREATE TYPE order_status AS ENUM ('pending','confirmed','preparing','shipped','delivered','cancelled');
CREATE TYPE payment_method AS ENUM ('cash_on_delivery','paymob_card','paymob_wallet');
CREATE TYPE payment_status AS ENUM ('pending','paid','failed','refunded');
CREATE TYPE post_type AS ENUM ('question','experience','announcement','discussion');
CREATE TYPE resource_type AS ENUM ('book','pdf','note','exam','review');

-- PROFILES
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL, full_name TEXT, username TEXT UNIQUE, phone TEXT,
  avatar_url TEXT, student_id TEXT, faculty faculty_type, academic_year SMALLINT,
  university_name TEXT, university_type TEXT DEFAULT 'public', bio TEXT,
  is_verified BOOLEAN DEFAULT FALSE, is_profile_complete BOOLEAN DEFAULT FALSE,
  preferred_language TEXT DEFAULT 'ar', preferred_theme TEXT DEFAULT 'light',
  fcm_token TEXT, push_notifications_enabled BOOLEAN DEFAULT TRUE,
  online_at TIMESTAMPTZ, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CATEGORIES + PRODUCTS
CREATE TABLE categories (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), name_en TEXT NOT NULL, name_ar TEXT NOT NULL, icon_url TEXT, sort_order INT DEFAULT 0, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE faculty_category_priority (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), faculty faculty_type NOT NULL, category_id UUID REFERENCES categories(id) ON DELETE CASCADE, priority_score INT DEFAULT 0);
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), name_en TEXT NOT NULL, name_ar TEXT NOT NULL,
  description_en TEXT, description_ar TEXT, price DECIMAL(10,2) NOT NULL, discount_price DECIMAL(10,2),
  stock_quantity INT DEFAULT 0, category_id UUID REFERENCES categories(id), images TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE, is_rentable BOOLEAN DEFAULT FALSE, rental_price_per_day DECIMAL(10,2),
  average_rating DECIMAL(3,2) DEFAULT 0, review_count INT DEFAULT 0, sold_count INT DEFAULT 0,
  tags TEXT[] DEFAULT '{}', created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CART + FAVORITES + ORDERS
CREATE TABLE cart_items (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID REFERENCES profiles(id) ON DELETE CASCADE, product_id UUID REFERENCES products(id) ON DELETE CASCADE, quantity INT DEFAULT 1, created_at TIMESTAMPTZ DEFAULT NOW(), UNIQUE(user_id, product_id));
CREATE TABLE favorites (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID REFERENCES profiles(id) ON DELETE CASCADE, product_id UUID REFERENCES products(id) ON DELETE CASCADE, created_at TIMESTAMPTZ DEFAULT NOW(), UNIQUE(user_id, product_id));
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), order_number TEXT UNIQUE, user_id UUID REFERENCES profiles(id),
  status order_status DEFAULT 'pending', payment_method payment_method DEFAULT 'cash_on_delivery',
  payment_status payment_status DEFAULT 'pending', paymob_order_id TEXT, paymob_transaction_id TEXT,
  subtotal DECIMAL(10,2), shipping_fee DECIMAL(10,2) DEFAULT 50, total DECIMAL(10,2),
  shipping_address JSONB, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE order_items (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), order_id UUID REFERENCES orders(id) ON DELETE CASCADE, product_id UUID REFERENCES products(id), quantity INT, unit_price DECIMAL(10,2), total_price DECIMAL(10,2), product_name_en TEXT, product_name_ar TEXT);

-- COMMUNITY
CREATE TABLE community_posts (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID REFERENCES profiles(id), post_type post_type DEFAULT 'discussion', title TEXT NOT NULL, body TEXT NOT NULL, images TEXT[] DEFAULT '{}', faculty faculty_type, upvote_count INT DEFAULT 0, comment_count INT DEFAULT 0, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE post_comments (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE, user_id UUID REFERENCES profiles(id), body TEXT NOT NULL, parent_id UUID REFERENCES post_comments(id), created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE post_upvotes (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE, user_id UUID REFERENCES profiles(id), created_at TIMESTAMPTZ DEFAULT NOW(), UNIQUE(post_id, user_id));
CREATE TABLE chat_conversations (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), participant_one UUID REFERENCES profiles(id), participant_two UUID REFERENCES profiles(id), last_message TEXT, last_message_at TIMESTAMPTZ DEFAULT NOW(), created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE chat_messages (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), conversation_id UUID REFERENCES chat_conversations(id) ON DELETE CASCADE, sender_id UUID REFERENCES profiles(id), body TEXT NOT NULL, file_url TEXT, is_read BOOLEAN DEFAULT FALSE, created_at TIMESTAMPTZ DEFAULT NOW());

-- STUDY
CREATE TABLE subjects (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), name_en TEXT NOT NULL, name_ar TEXT NOT NULL, faculty faculty_type NOT NULL, academic_year SMALLINT, created_at TIMESTAMPTZ DEFAULT NOW(), UNIQUE(name_en, faculty));
CREATE TABLE resources (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE, user_id UUID REFERENCES profiles(id), title TEXT NOT NULL, description TEXT, resource_type resource_type DEFAULT 'pdf', file_url TEXT, download_count INT DEFAULT 0, created_at TIMESTAMPTZ DEFAULT NOW());

-- NOTIFICATIONS + ROTATIONS
CREATE TABLE notifications (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID REFERENCES profiles(id) ON DELETE CASCADE, title TEXT NOT NULL, body TEXT NOT NULL, type TEXT, reference_id UUID, is_read BOOLEAN DEFAULT FALSE, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE rotations (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID REFERENCES profiles(id) ON DELETE CASCADE, department TEXT NOT NULL, hospital TEXT NOT NULL, start_date DATE, end_date DATE, rating SMALLINT, review TEXT, is_public BOOLEAN DEFAULT TRUE, created_at TIMESTAMPTZ DEFAULT NOW());

-- TRIGGERS
CREATE OR REPLACE FUNCTION update_updated_at() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_profiles_upd BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_products_upd BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_orders_upd BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE OR REPLACE FUNCTION generate_order_number() RETURNS TRIGGER AS $$ BEGIN NEW.order_number = 'SEC-' || TO_CHAR(NOW(),'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM()*99999)::TEXT,5,'0'); RETURN NEW; END; $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_order_num BEFORE INSERT ON orders FOR EACH ROW EXECUTE FUNCTION generate_order_number();

CREATE OR REPLACE FUNCTION handle_new_user() RETURNS TRIGGER AS $$ BEGIN INSERT INTO public.profiles (id, email) VALUES (NEW.id, NEW.email); RETURN NEW; END; $$ LANGUAGE plpgsql SECURITY DEFINER;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();

CREATE OR REPLACE FUNCTION increment_download_count(resource_id UUID) RETURNS void AS $$ UPDATE resources SET download_count = download_count + 1 WHERE id = resource_id; $$ LANGUAGE sql;

-- RLS POLICIES
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_upvotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE rotations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "own_profile_update" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "own_favorites" ON favorites USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_cart" ON cart_items USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_orders_read" ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "own_orders_create" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "auth_read_posts" ON community_posts FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth_create_posts" ON community_posts FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_posts_update" ON community_posts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "auth_read_comments" ON post_comments FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth_create_comments" ON post_comments FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "auth_upvotes" ON post_upvotes USING (auth.uid() = user_id);
CREATE POLICY "auth_read_resources" ON resources FOR SELECT TO authenticated USING (true);
CREATE POLICY "auth_add_resources" ON resources FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "public_rotations" ON rotations FOR SELECT USING (is_public = true OR auth.uid() = user_id);
CREATE POLICY "own_rotations" ON rotations USING (auth.uid() = user_id);
CREATE POLICY "own_chats" ON chat_conversations FOR SELECT USING (auth.uid() = participant_one OR auth.uid() = participant_two);
CREATE POLICY "create_chats" ON chat_conversations FOR INSERT WITH CHECK (auth.uid() = participant_one);
CREATE POLICY "own_chat_messages" ON chat_messages FOR SELECT USING (EXISTS (SELECT 1 FROM chat_conversations c WHERE c.id = conversation_id AND (c.participant_one = auth.uid() OR c.participant_two = auth.uid())));
CREATE POLICY "send_chat_messages" ON chat_messages FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "public_subjects" ON subjects FOR SELECT USING (true);
CREATE POLICY "auth_add_subjects" ON subjects FOR INSERT TO authenticated WITH CHECK (true);

-- SEED DATA
INSERT INTO categories (name_en, name_ar, sort_order) VALUES
('Stethoscopes','سماعات الطبيب',1),('Scrubs & Uniforms','سكراب وملابس طبية',2),
('Medical Books','كتب طبية',3),('Diagnostic Tools','أدوات تشخيصية',4),
('Lab Equipment','معدات مختبر',5),('Dental Tools','أدوات أسنان',6),
('Anatomy Models','نماذج تشريح',7),('First Aid','إسعافات أولية',8),
('Stationery','قرطاسية طبية',9),('Bags & Cases','حقائب وحافظات',10);
