import {createClient} from '@supabase/supabase-js';
const url=import.meta.env.VITE_SUPABASE_URL||'';
const anonKey=import.meta.env.VITE_SUPABASE_ANON_KEY||'';
export const backendReady=Boolean(url&&anonKey);
export const supabase=backendReady?createClient(url,anonKey):null;
export const auth={
  signUp:(email,password)=>supabase.auth.signUp({email,password}),
  signIn:(email,password)=>supabase.auth.signInWithPassword({email,password}),
  signOut:()=>supabase.auth.signOut(),
  session:()=>supabase.auth.getSession()
};
export async function uploadFile(file,userId,title=''){
  if(!backendReady) throw new Error('Connect Supabase first.');
  const safe=file.name.replace(/[^a-zA-Z0-9._-]/g,'_');
  const path=`${userId}/${crypto.randomUUID()}-${safe}`;
  const {error:upErr}=await supabase.storage.from('user-files').upload(path,file,{contentType:file.type,upsert:false});
  if(upErr) throw upErr;
  const slug=crypto.randomUUID().replaceAll('-','').slice(0,14);
  const {data,error}=await supabase.from('files').insert({owner_id:userId,slug,title:title||file.name,storage_path:path,mime_type:file.type,size_bytes:file.size}).select().single();
  if(error){await supabase.storage.from('user-files').remove([path]);throw error;}
  return data;
}
export async function myFiles(userId){const {data,error}=await supabase.from('files').select('*').eq('owner_id',userId).neq('status','deleted').order('created_at',{ascending:false});if(error)throw error;return data;}
export async function publicFile(slug){const {data,error}=await supabase.from('files').select('id,slug,title,description,mime_type,size_bytes,downloads,created_at,status').eq('slug',slug).eq('status','active').single();if(error)throw error;return data;}
