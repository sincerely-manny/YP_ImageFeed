import { serve } from '@hono/node-server';
import { randomInt } from 'crypto';
import fs from 'fs';
import { Hono } from 'hono';
import path from 'path';
import sharp from 'sharp';
import { fileURLToPath } from 'url';
import { v4 as uuidv4 } from 'uuid';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const imagesDir = path.join(__dirname, 'images');

// Make sure the images directory exists
if (!fs.existsSync(imagesDir)) {
  fs.mkdirSync(imagesDir, { recursive: true });
}

const app = new Hono();

// In-memory storage for our mock data
const users = [];
const photos = [];
const accessTokens = {};

// Generate random data
async function generateRandomImages() {
  const getRandomDate = () => {
    const start = new Date(2020, 0, 1);
    const end = new Date();
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime())).toISOString();
  };

  const getRandomBoolean = () => Math.random() > 0.5;
  const getRandomColor = () => {
    const colors = [
      '#FF5733', '#33FF57', '#3357FF', '#F3FF33', '#FF33F3',
      '#33FFF3', '#FF8C33', '#8C33FF', '#FF3333', '#33FF33'
    ];
    return colors[Math.floor(Math.random() * colors.length)];
  };

  // Create a mock user if none exist
  if (users.length === 0) {
    const userId = uuidv4();
    // Create user avatar
    await createCircleAvatar(userId, 256, '#3498db');

    users.push({
      id: userId,
      username: 'mockuser',
      name: 'John Doe',
      firstName: 'John',
      lastName: 'Doe',
      bio: 'This is a mock user for testing. Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      email: 'mock@example.com',
      profileImage: {
        small: `http://localhost:3000/images/avatar-${userId}-small.jpg`,
        medium: `http://localhost:3000/images/avatar-${userId}-medium.jpg`,
        large: `http://localhost:3000/images/avatar-${userId}-large.jpg`,
      }
    });
  }

  // Generate 20 mock photos
  if (photos.length === 0) {
    console.log('Generating random images...');

    for (let i = 0; i < 20; i++) {
      const id = uuidv4();
      const width = randomInt(800, 1600);
      const height = randomInt(600, 1200);
      const color = getRandomColor();

      // Generate actual images with different sizes
      await createImageWithText(id, 100, 100, color, `Thumb ${i+1}`);
      await createImageWithText(id, 400, 300, color, `Small ${i+1}`);
      await createImageWithText(id, 800, 600, color, `Regular ${i+1}`);
      await createImageWithText(id, 1200, 900, color, `Full ${i+1}`);
      await createImageWithText(id, width, height, color, `Photo ${i+1}`);

      photos.push({
        id,
        createdAt: getRandomDate(),
        updatedAt: getRandomDate(),
        width,
        height,
        color,
        blurHash: 'LGF5?xYk^6#M@-5c,1J5@[or[Q6.',
        likes: randomInt(0, 1000),
        likedByUser: getRandomBoolean(),
        description: `Beautiful landscape photo ${i + 1}. This is a mock description for testing purposes.`,
        user: users[0],
        urls: {
          raw: `http://localhost:3000/images/photo-${id}-raw.jpg`,
          full: `http://localhost:3000/images/photo-${id}-full.jpg`,
          regular: `http://localhost:3000/images/photo-${id}-regular.jpg`,
          small: `http://localhost:3000/images/photo-${id}-small.jpg`,
          thumb: `http://localhost:3000/images/photo-${id}-thumb.jpg`,
        }
      });
    }
    console.log('Image generation complete!');
  }
}

// Create a colored image with text
async function createImageWithText(id, width, height, color, text) {
  const size = text.includes('Thumb') ? 'thumb' :
               text.includes('Small') ? 'small' :
               text.includes('Regular') ? 'regular' :
               text.includes('Full') ? 'full' : 'raw';

  const filePath = path.join(imagesDir, `photo-${id}-${size}.jpg`);

  if (!fs.existsSync(filePath)) {
    // Create a colored SVG with text
    const svgBuffer = Buffer.from(`
      <svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="${color}" />
        <text x="50%" y="50%" font-family="Arial" font-size="${Math.max(20, width/20)}px"
              fill="white" text-anchor="middle" dominant-baseline="middle">
          ${text}
        </text>
        <text x="50%" y="${height - 30}" font-family="Arial" font-size="${Math.max(16, width/30)}px"
              fill="white" text-anchor="middle" dominant-baseline="middle">
          ${width}x${height}
        </text>
      </svg>
    `);

    await sharp(svgBuffer)
      .jpeg({ quality: 90 })
      .toFile(filePath);
  }
}

// Create a circle avatar
async function createCircleAvatar(userId, size, color) {
  const sizes = {
    small: 32,
    medium: 128,
    large: 256
  };

  for (const [key, dimension] of Object.entries(sizes)) {
    const filePath = path.join(imagesDir, `avatar-${userId}-${key}.jpg`);

    if (!fs.existsSync(filePath)) {
      // Create a circular avatar
      const svgBuffer = Buffer.from(`
        <svg width="${dimension}" height="${dimension}" xmlns="http://www.w3.org/2000/svg">
          <circle cx="${dimension/2}" cy="${dimension/2}" r="${dimension/2}" fill="${color}" />
          <text x="50%" y="50%" font-family="Arial" font-size="${dimension/4}px"
                fill="white" text-anchor="middle" dominant-baseline="middle">
            JD
          </text>
        </svg>
      `);

      await sharp(svgBuffer)
        .jpeg({ quality: 90 })
        .toFile(filePath);
    }
  }
}

// delete all images
async function deleteAllImages() {
  console.log('Deleting old images...');
  const files = fs.readdirSync(imagesDir);
  for (const file of files) {
    const filePath = path.join(imagesDir, file);
    fs.unlink(filePath, (err) => {
      if (err) {
        console.error(`Error deleting file ${filePath}:`, err);
      }
    });
  }
}
await deleteAllImages();


// Generate data when the server starts
await generateRandomImages();

// Serve static files from the images directory
app.get('/images/:filename', async (c) => {
  const filename = c.req.param('filename');
  const filePath = path.join(imagesDir, filename);

  if (fs.existsSync(filePath)) {
    const buffer = fs.readFileSync(filePath);
    return new Response(buffer, {
      headers: {
        'Content-Type': 'image/jpeg',
        'Cache-Control': 'public, max-age=86400'
      }
    });
  } else {
    return c.notFound();
  }
});

// OAuth token endpoint
app.post('/oauth/token', async (c) => {
  const body = await c.req.parseBody();
  const { code, grant_type, client_id, client_secret, redirect_uri } = body;

  if (grant_type !== 'authorization_code') {
    return c.json({ error: 'invalid_grant' }, 400);
  }

  // Generate a token
  const token = uuidv4();
  const createdAt = Math.floor(Date.now() / 1000);

  // Store the token
  accessTokens[token] = {
    userId: users[0].id,
    createdAt
  };

  return c.json({
    accessToken: token,
    tokenType: 'bearer',
    scope: 'public read_user write_likes',
    createdAt
  });
});

// Get profile endpoint
app.get('/me', async (c) => {
  const authHeader = c.req.header('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized' }, 401);
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    return c.json({ error: 'Invalid token' }, 401);
  }
  // if (!accessTokens[token]) {
  //   return c.json({ error: 'Invalid token' }, 401);
  // }

  return c.json({
    id: users[0].id,
    username: users[0].username,
    firstName: users[0].firstName,
    lastName: users[0].lastName,
    bio: users[0].bio,
    email: users[0].email
  });
});

// Get user's profile
app.get('/users/:username', async (c) => {
  const username = c.req.param('username');
  const user = users.find(u => u.username === username);

  if (!user) {
    return c.json({ error: 'User not found' }, 404);
  }

  return c.json(user);
});

// Get photos endpoint
app.get('/photos', async (c) => {
  const page = parseInt(c.req.query('page') || '1');
  const perPage = parseInt(c.req.query('per_page') || '10');

  const start = (page - 1) * perPage;
  const end = start + perPage;

  return c.json(photos.slice(start, end));
});

// Get a specific photo
app.get('/photos/:id', async (c) => {
  const photoId = c.req.param('id');
  const photo = photos.find(p => p.id === photoId);

  if (!photo) {
    return c.json({ error: 'Photo not found' }, 404);
  }

  return c.json(photo);
});

// Like/unlike a photo
app.post('/photos/:id/like', async (c) => {
  const photoId = c.req.param('id');
  const photo = photos.find(p => p.id === photoId);

  if (!photo) {
    return c.json({ error: 'Photo not found' }, 404);
  }

  photo.likedByUser = true;
  photo.likes += 1;

  return c.json({
    photo,
    user: users[0]
  });
});

app.delete('/photos/:id/like', async (c) => {
  const photoId = c.req.param('id');
  const photo = photos.find(p => p.id === photoId);

  if (!photo) {
    return c.json({ error: 'Photo not found' }, 404);
  }

  photo.likedByUser = false;
  photo.likes = Math.max(0, photo.likes - 1);

  return c.json({
    photo,
    user: users[0]
  });
});

// Status endpoint to check if server is running
app.get('/', (c) => {
  return c.json({
    status: 'ok',
    message: 'Unsplash API Mock Server is running',
    endpoints: [
      '/photos',
      '/photos/:id',
      '/photos/:id/like',
      '/me',
      '/users/:username',
      '/oauth/token'
    ],
    timestamp: new Date().toISOString()
  });
});

console.log('Starting mock server on http://localhost:3000');
serve({
  fetch: app.fetch,
  port: 3000
});
