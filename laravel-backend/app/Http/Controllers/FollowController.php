<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Follow;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Storage;

class FollowController extends Controller
{
    public function toggle(Request $request, User $user)
    {
        if ($user->id === $request->user()->id) {
            return response()->json(['message' => 'Cannot follow yourself'], 422);
        }

        $follow = Follow::where('follower_id', $request->user()->id)
            ->where('followed_id', $user->id)
            ->first();

        if ($follow) {
            $follow->delete();
            return response()->json(['status' => 'unfollowed']);
        }

        Follow::create([
            'follower_id' => $request->user()->id,
            'followed_id' => $user->id,
        ]);

        return response()->json(['status' => 'followed']);
    }

    public function search(Request $request)
    {
        $search = $request->query('search', '');
        $users = User::where('username', 'like', "$search%")
            ->where('id', '!=', $request->user()->id)
            ->withCount(['followers as is_followed' => function ($query) use ($request) {
                $query->where('follower_id', $request->user()->id);
            }])
            ->orderByDesc('is_followed')
            ->orderBy('username')
            ->get()
            ->map(function ($user) {
                $user->profile_picture_url = $user->profile_picture ? Storage::url($user->profile_picture) : null;
                return $user;
            });

        return response()->json($users);
    }

    public function following(Request $request)
    {
        $followedIds = $request->user()->following()
            ->pluck('followed_id');
            
        $following = User::whereIn('id', $followedIds)
            ->get()
            ->map(function ($user) {
                $user->profile_picture_url = $user->profile_picture ? Storage::url($user->profile_picture) : null;
                $user->is_followed = 1;
                return $user;
            });

        return response()->json($following);
    }

    public function followers(Request $request)
    {
        $followerIds = $request->user()->followers()
            ->pluck('follower_id');
            
        $followers = User::whereIn('id', $followerIds)
            ->get()
            ->map(function ($user) use ($request) {
                $user->profile_picture_url = $user->profile_picture ? Storage::url($user->profile_picture) : null;
                
                $user->is_followed = Follow::where('follower_id', $request->user()->id)
                    ->where('followed_id', $user->id)
                    ->exists() ? 1 : 0;
                
                return $user;
            });

        return response()->json($followers);
    }

    public function followBack(Request $request)
    {
        $followerIds = $request->user()->followers()
            ->whereNotExists(function ($query) use ($request) {
                $query->select(DB::raw(1))
                    ->from('follows as f')
                    ->whereRaw('f.followed_id = follows.follower_id')
                    ->where('f.follower_id', $request->user()->id);
            })
            ->pluck('follower_id');
            
        $followBack = User::whereIn('id', $followerIds)
            ->get()
            ->map(function ($user) {
                $user->profile_picture_url = $user->profile_picture ? Storage::url($user->profile_picture) : null;
                $user->is_followed = 0;
                return $user;
            });

        return response()->json($followBack);
    }

    public function explore(Request $request)
    {
        $explore = User::where('id', '!=', $request->user()->id)
            ->whereNotExists(function ($query) use ($request) {
                $query->select(DB::raw(1))
                    ->from('follows')
                    ->whereRaw('follows.followed_id = users.id')
                    ->where('follows.follower_id', $request->user()->id);
            })
            ->orderBy('created_at', 'desc')
            ->take(20)
            ->get()
            ->map(function ($user) {
                $user->profile_picture_url = $user->profile_picture ? Storage::url($user->profile_picture) : null;
                $user->is_followed = 0;
                return $user;
            });

        return response()->json($explore);
    }
}
