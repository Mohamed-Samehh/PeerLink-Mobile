<?php

namespace App\Http\Controllers;

use App\Models\Like;
use App\Models\Post;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Storage;

class LikeController extends Controller
{
    public function toggle(Request $request, Post $post)
    {
        $like = Like::where('user_id', $request->user()->id)
            ->where('post_id', $post->id)
            ->first();

        if ($like) {
            $like->delete();
            return response()->json(['status' => 'unliked']);
        }

        Like::create([
            'user_id' => $request->user()->id,
            'post_id' => $post->id,
        ]);

        return response()->json(['status' => 'liked']);
    }

    public function index(Request $request, Post $post)
    {
        $likes = $post->likes()->with('user')->get()->map(function ($like) {
            $like->user->profile_picture_url = $like->user->profile_picture ? Storage::url($like->user->profile_picture) : null;
            return $like;
        });

        return response()->json($likes);
    }
}
