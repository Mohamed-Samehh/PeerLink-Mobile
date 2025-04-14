<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class PostController extends Controller
{
    public function index(Request $request)
    {
        if (!$request->user()) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $posts = Post::where('user_id', $request->user()->id)
            ->orWhereIn('user_id', $request->user()->following()->pluck('followed_id'))
            ->with(['user', 'likes'])
            ->orderBy('id', 'desc')
            ->get()
            ->map(function ($post) use ($request) {
                $post->image_url = $post->image ? Storage::url($post->image) : null;
                $post->user_liked = $post->likes->contains('user_id', $request->user()->id);
                return $post;
            });

        return response()->json($posts);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = [
            'user_id' => $request->user()->id,
            'content' => $request->content,
        ];

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('posts', 'public');
        }

        $post = Post::create($data);
        $post->load('user', 'likes');
        $post->image_url = $post->image ? Storage::url($post->image) : null;

        return response()->json($post, 201);
    }

    public function destroy(Request $request, Post $post)
    {
        if ($post->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($post->image) {
            Storage::disk('public')->delete($post->image);
        }

        $post->delete();
        return response()->json(['message' => 'Post deleted']);
    }
}
