-- Create teacher_profiles table
CREATE TABLE IF NOT EXISTS teacher_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  
  -- Basic Info (Step 1)
  full_name TEXT NOT NULL,
  specializations TEXT[] NOT NULL,
  years_experience INTEGER DEFAULT 0,
  bio TEXT,
  teach_online BOOLEAN DEFAULT false,
  teach_offline BOOLEAN DEFAULT false,
  locations TEXT[] DEFAULT '{}',
  
  -- Pricing Info (Step 2)
  price_online INTEGER,
  price_offline INTEGER,
  bundle_8_sessions INTEGER DEFAULT 8,
  bundle_8_discount NUMERIC DEFAULT 10,
  bundle_12_sessions INTEGER DEFAULT 12,
  bundle_12_discount NUMERIC DEFAULT 15,
  allow_trial_lesson BOOLEAN DEFAULT true,
  
  -- Verification Info (Step 3)
  id_number TEXT,
  id_front_url TEXT,
  id_back_url TEXT,
  bank_name TEXT,
  bank_account TEXT,
  account_holder TEXT,
  certificates_description TEXT,
  certificate_urls TEXT[] DEFAULT '{}',
  
  -- Media
  avatar_url TEXT,
  video_demo_url TEXT,
  
  -- Status
  verification_status TEXT DEFAULT 'pending', -- pending, approved, rejected
  rejected_reason TEXT,
  approved_at TIMESTAMP,
  
  -- Meta
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_user_id ON teacher_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_status ON teacher_profiles(verification_status);
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_specializations ON teacher_profiles USING GIN(specializations);
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_locations ON teacher_profiles USING GIN(locations);

-- RLS (Row Level Security) Policies
ALTER TABLE teacher_profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own profile
CREATE POLICY "Users can view their own profile"
  ON teacher_profiles FOR SELECT
  USING (auth.uid() = user_id);

-- Allow users to insert their own profile
CREATE POLICY "Users can insert their own profile"
  ON teacher_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own profile
CREATE POLICY "Users can update their own profile"
  ON teacher_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- Allow anyone to view approved teacher profiles
CREATE POLICY "Anyone can view approved profiles"
  ON teacher_profiles FOR SELECT
  USING (verification_status = 'approved');

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_teacher_profile_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS trigger_update_teacher_profile_timestamp ON teacher_profiles;
CREATE TRIGGER trigger_update_teacher_profile_timestamp
  BEFORE UPDATE ON teacher_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_teacher_profile_updated_at();

-- Create storage bucket for profile images
INSERT INTO storage.buckets (id, name, public)
VALUES ('teacher-profiles', 'teacher-profiles', true)
ON CONFLICT DO NOTHING;

-- Storage policies for teacher-profiles bucket
CREATE POLICY "Anyone can view profile images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'teacher-profiles');

CREATE POLICY "Authenticated users can upload profile images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'teacher-profiles' AND auth.role() = 'authenticated');

CREATE POLICY "Users can update their own profile images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'teacher-profiles' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own profile images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'teacher-profiles' AND auth.uid()::text = (storage.foldername(name))[1]);
